export Client,
    me,
    add_handler!,
    delete_handler!,
    request_guild_members,
    update_voice_status,
    update_status

# Properties for gateway connections.
const conn_properties = Dict(
    "\$os"      => string(Sys.KERNEL),
    "\$browser" => "Discord.jl",
    "\$device"  => "Discord.jl",
)

const OPCODES = Dict(
    0 =>  :DISPATCH,
    1 =>  :HEARTBEAT,
    2 =>  :IDENTIFY,
    3 =>  :STATUS_UPDATE,
    4 =>  :VOICE_STATUS_UPDATE,
    6 =>  :RESUME,
    7 =>  :RECONNECT,
    8 =>  :REQUEST_GUILD_MEMBERS,
    9 =>  :INVALID_SESSION,
    10 => :HELLO,
    11 => :HEARTBEAT_ACK,
)

mutable struct Handler
    f::Function
    tag::Symbol
    expiry::Union{Int, DateTime}  # -1 for no expiry.
end

Handler(f::Function) = Handler(f, gensym(), -1)
Handler(f::Function, tag::Symbol, expiry::Period) = Handler(f, tag, now(UTC) + expiry)

isexpired(h::Handler) = h.expiry isa Int ? h.expiry == 0 : now(UTC) > h.expiry

struct Conn
    io
    v::Int
end

"""
    Client(token::String; ttl::Period=Hour(1), version::Int=$API_VERSION) -> Client

A Discord bot. `Client`s can connect to the gateway, respond to events, and make REST API
calls to perform actions such as sending/deleting messages, kicking/banning users, etc.

To get a bot token, head [here](https://discordapp.com/developers/applications) to create a
new application. Once you've created a bot user, you will have access to its token.

# Keywords
- `ttl::Period=Hour(1)` Amount of time that cache entries are kept (see "Caching" below for
  more details).
- `version::Int=$API_VERSION`: Version of the Discord API to use. Using anything but
  $API_VERSION is not officially supported by the Discord.jl developers.

# Caching
By default, most data that comes from Discord is cached for later use. However, to avoid
memory leakage, it's deleted after some time (determined by the `ttl` keyword). Although
it's not recommended, you can also disable caching of certain data by clearing default
handlers for relevant event types with [`delete_handler!`](@ref). For example, if you
wanted to avoid caching any messages, you would delete handlers for [`MessageCreate`](@ref)
and [`MessageUpdate`](@ref) events.

# Sharding
Sharding is handled automatically: The number of available processes is the number of
shards that are created. See the
[sharding example](https://github.com/PurgePJ/Discord.jl/blob/master/examples/sharding.jl)
for more details.
"""
mutable struct Client
    token::String               # Bot token, always with a leading "Bot ".
    heartbeat_interval::Int     # Milliseconds between heartbeats.
    heartbeat_seq::Union{Int, Nothing}  # Sequence value sent by Discord for resuming.
    last_heartbeat::DateTime    # Last heartbeat send.
    last_ack::DateTime          # Last heartbeat ack.
    ttl::Period                 # Cache lifetime.
    version::Int                # Discord API version.
    state::State                # Client state, cached data, etc.
    shards::Int                 # Number of shards in use.
    shard::Int                  # Client's shard index.
    limiter::Limiter            # Rate limiter.
    handlers::Dict{Type{<:AbstractEvent}, Set{Handler}}  # Event handlers.
    ready::Bool                 # Client is connected and authenticated.
    conn::Conn                  # WebSocket connection.

    function Client(token::String; ttl::Period=Hour(1), version::Int=API_VERSION)
        token = startswith(token, "Bot ") ? token : "Bot $token"
        c = new(
            token,        # token
            0,            # heartbeat_interval
            nothing,      # heartbeat_seq
            DateTime(0),  # last_heartbeat
            DateTime(0),  # last_ack
            ttl,          # ttl
            version,      # version
            State(ttl),   # state
            nprocs(),     # shards
            myid() - 1,   # shard
            Limiter(),    # limiter
            Dict(),       # handlers
            false,        # ready
            # conn left undef, it gets assigned in open.
        )
        add_handler!(c, Defaults)
        return c
    end
end

"""
    open(c::Client; delay::Period=Second(7))

Connect to the Discord gateway and begin responding to events.

The `delay` keyword is the number of seconds between shards connecting. It can be increased
from its default if you are frequently experiencing invalid sessions upon connection.
"""
function Base.open(c::Client; resume::Bool=false, delay::Period=Second(7))
    isopen(c) && error("Client is already open")
    c.ready = false

    # Clients can only identify once per 5 seconds.
    resume || sleep(c.shard * delay)

    logmsg(c, DEBUG, "Requesting gateway URL")
    resp = HTTP.get("$DISCORD_API/v$(c.version)/gateway")
    data = JSON.parse(String(resp.body))
    url = "$(data["url"])?v=$(c.version)&encoding=json"
    logmsg(c, DEBUG, "Connecting to gateway"; url=url)
    c.conn = Conn(opentrick(WebSockets.open, url), isdefined(c, :conn) ? c.conn.v + 1 : 1)

    logmsg(c, DEBUG, "receiving HELLO"; conn=c.conn.v)
    data, e = readjson(c.conn.io)
    e === nothing || throw(e)
    op = get(OPCODES, data["op"], data["op"])
    op === :HELLO || error("Expected opcode HELLO, received $op")
    hello(c, data)

    data = if resume
        Dict("op" => 6, "d" => Dict(
            "token" => c.token,
            "session_id" => c.state.session_id,
            "seq" => c.heartbeat_seq,
        ))
    else
        d = Dict("op" => 2, "s" => c.heartbeat_seq, "d" => Dict(
                "token" => c.token,
                "properties" => conn_properties
        ))

        if c.shards > 1
            d["d"]["shard"] = [c.shard, c.shards]
        end
        d
    end

    op = resume ? :RESUME : :IDENTIFY
    logmsg(c, DEBUG, "Writing $op"; conn=c.conn.v)
    writejson(c.conn.io, data) || error("Writing $op failed")

    logmsg(c, DEBUG, "Starting background maintenance tasks"; conn=c.conn.v)
    @async heartbeat_loop(c)
    @async read_loop(c)

    c.ready = true
end

"""
    isopen(c::Client) -> Bool

Determine whether the client is connected to the gateway.
"""
Base.isopen(c::Client) = c.ready && isdefined(c, :conn) && isopen(c.conn.io)

"""
    Base.close(c::Client)

Disconnect from the Discord gateway.
"""
function Base.close(c::Client; statusnumber::Int=1000)
    c.ready = false
    isdefined(c, :conn) && close(c.conn.io; statusnumber=statusnumber)
end

"""
    wait(c::Client)

Wait for an open client to close.
"""
Base.wait(c::Client) = isopen(c) && wait(c.conn.io.cond)

"""
    me(c::Client) -> Union{User, Nothing}

Get the client's bot user.
"""
me(c::Client) = c.state.user

# Gateway commands.

"""
    request_guild_members(
        c::Client,
        guild_id::Union{Snowflake, Vector{Snowflake};
        query::AbstractString="",
        limit::Int=0,
    ) -> Bool

Request offline guild members of one or more guilds. [`GuildMembersChunk`](@ref) events are
sent by the gateway in response.

More details [here](https://discordapp.com/developers/docs/topics/gateway#request-guild-members).
"""
function request_guild_members(
    c::Client,
    guild_id::Snowflake;
    query::AbstractString="",
    limit::Int=0,
)
    return request_guild_members(c, [guild_id]; query=query, limit=limit)
end

function request_guild_members(
    c::Client,
    guild_id::Vector{Snowflake};
    query::AbstractString="",
    limit::Int=0,
)
    return writejson(c.conn.io, Dict("op" => 8, "d" => Dict(
        "guild_id" => guild_id,
        "query" => query,
        "limit" => limit,
    )))
end

"""
    update_voice_state(
        c::Client,
        guild_id::Snowflake,
        channel_id::Union{Snowflake, Nothing},
        self_mute::Bool,
        self_deaf::Bool,
    ) -> Bool

Join, move, or disconnect from a voice channel. A [`VoiceStateUpdate`](@ref) event is sent
by the gateway in response.

More details [here](https://discordapp.com/developers/docs/topics/gateway#update-voice-state).
"""
function update_voice_state(
    c::Client,
    guild_id::Snowflake,
    channel_id::Union{Snowflake, Nothing},
    self_mute::Bool,
    self_deaf::Bool,
)
    return writejson(c.conn.io, Dict("op" => 4, "d" => Dict(
        "guild_id" => guild_id,
        "channel_id" => channel_id,
        "self_mute" => self_mute,
        "self_deaf" => self_deaf,
    )))
end

"""
    update_status(
        c::Client,
        since::Union{Int, Nothing},
        activity::Union{Activity, Nothing},
        status::PresenceStatus,
        afk::Bool,
    ) -> Bool

Indicate a presence or status update. A [`PresenceUpdate`](@ref) event is sent by the
gateway in response.

More details [here](https://discordapp.com/developers/docs/topics/gateway#update-status).
"""
function update_status(
    c::Client,
    since::Union{Int, Nothing},
    activity::Union{Activity, Nothing},
    status::PresenceStatus,
    afk::Bool,
)
    return writejson(c.conn.io, Dict("op" => 3, "d" => Dict(
        "since" => since,
        "activity" => activity,
        "status" => status,
        "afk" => afk,
    )))
end

# Handler insertion/deletion.

"""
    add_handler!(
        c::Client,
        evt::Type{<:AbstractEvent},
        func::Function;
        tag::Symbol=gensym(),
        expiry::Union{Int, Period}=-1,
    )

Add an event handler. The handler should be a function which takes two arguments: A
[`Client`](@ref) and an [`AbstractEvent`](@ref) (or a subtype). The handler is appended to
the event's current handlers.

# Keywords
- `tag::Symbol=gensym()`: A label for the handler, which can be used to remove it with
  [`delete_handler!`](@ref).
- `expiry::Union{Int, Period}=-1`: The handler's expiry. If an `Int` is given, the handler
  will run a set number of times before expiring. If a `Period` is given, the handler will
  expire after that amount of time has elapsed. The default of `-1` indicates no expiry.

!!! note
    There is no guarantee on the order in which handlers run, except that catch-all
    ([`AbstractEvent`](@ref)) handlers run before specific ones.
"""
function add_handler!(
    c::Client,
    evt::Type{<:AbstractEvent},
    func::Function;
    tag::Symbol=gensym(),
    expiry::Union{Int, Period}=-1,
)
    if !hasmethod(func, (Client, evt))
        error("Handler function must accept (::Client, ::$evt)")
    end

    expiry == 0 && error("Can't add a handler that will never run")
    delete_handler!(c, evt, tag)

    h = Handler(func, tag, expiry)
    if haskey(c.handlers, evt)
        push!(c.handlers[evt], h)
    else
        c.handlers[evt] = Set([h])
    end
end

"""
    add_handler!(c::Client, m::Module)

Add all of the event handlers defined in a module. Any function you wish to use as a
handler must be exported. Only functions with correct type signatures (see above) are used.
"""
function add_handler!(c::Client, m::Module)
    # TODO: This is super hacky and relies on internal struct fields which is ugly.
    for f in filter(f -> f isa Function, map(n -> getfield(m, n), names(m)))
        for m in methods(f).ms
            ts = m.sig.types[2:end]
            length(m.sig.types) == 3 || continue
            if m.sig.types[2] === Client && m.sig.types[3] <: AbstractEvent
                add_handler!(c, m.sig.types[3], f)
            end
        end
    end
end

"""
    delete_handler!(c::Client, evt::Type{<:AbstractEvent})
    delete_handler!(c::Client, evt::Type{<:AbstractEvent}, tag::Symbol)

Delete event handlers. If no `tag` is supplied, all handlers for the event are deleted.
Using the tagless method is generally not recommended because it also clears default
handlers which maintain the client state.
"""
delete_handler!(c::Client, evt::Type{<:AbstractEvent}) = delete!(c.handlers, evt)

function delete_handler!(c::Client, evt::Type{<:AbstractEvent}, tag::Symbol)
    filter!(h -> h.tag !== tag, get(c.handlers, evt, []))
end

# Client maintenance.

function heartbeat_loop(c::Client)
    v = c.conn.v

    while c.conn.v == v && isopen(c)
        sleep(c.heartbeat_interval / 1000)
        if c.last_heartbeat > c.last_ack && isopen(c) && c.conn.v == v
            logmsg(c, DEBUG, "Encountered zombie connection"; conn=v)
            reconnect(c; resume=true)
        elseif !heartbeat(c) && c.conn.v == v && isopen(c)
            logmsg(c, ERROR, "Writing HEARTBEAT failed"; conn=v)
        end
    end
    logmsg(c, DEBUG, "Heartbeat loop exited"; conn=v)
end

function read_loop(c::Client)
    v = c.conn.v

    while c.conn.v == v && isopen(c)
        data, e = readjson(c.conn.io)
        if e !== nothing && c.conn.v == v
            handle_read_error(c, e)
        elseif e !== nothing
            logmsg(c, DEBUG, "Read failed, but the connection is outdated"; conn=v, e=e)
        elseif haskey(HANDLERS, data["op"])
            HANDLERS[data["op"]](c, data)
        else
            logmsg(c, WARN, "Unkown opcode"; op=data["op"])
        end
    end
    logmsg(c, DEBUG, "Read loop exited"; conn=v)
end

# Event handlers.

function dispatch(c::Client, data::AbstractDict)
    c.heartbeat_seq = data["s"]

    T = get(EVENT_TYPES, data["t"], UnknownEvent)
    haskey(c.handlers, T) || return

    evt = try
        T(T === UnknownEvent ? data : data["d"])
    catch e
        err = sprint(showerror, e) * sprint(Base.show_backtrace, catch_backtrace())
        logmsg(c, ERROR, err; type=data["t"])
        UnknownEvent(data)
    end

    catchalls = collect(get(c.handlers, AbstractEvent, []))
    specifics = collect(get(c.handlers, T, []))

    for handler in [catchalls; specifics]
        @async try
            handler.f(c, evt)
        catch e
            err = sprint(showerror, e) * sprint(Base.show_backtrace, catch_backtrace())
            logmsg(c, ERROR, err; event=T, handler=handler.tag)
        finally
            if handler.remaining != -1
                handler.remaining -= 1
            end
        end
    end

    filter!(!isexpired, get(c.handlers, AbstractEvent, []))
    filter!(!isexpired, get(c.handlers, T, []))
end

function heartbeat(c::Client, ::AbstractDict=Dict())
    ok = writejson(c.conn.io, Dict("op" => 1, "d" => c.heartbeat_seq))
    if ok
        c.last_heartbeat = now()
    end
    return ok
end

function reconnect(c::Client, ::AbstractDict=Dict(); resume::Bool=false)
    logmsg(c, INFO, "Reconnecting"; resume=resume)
    close(c; statusnumber=resume ? 4000 : 1000)
    open(c; resume=resume)
end

function invalid_session(c::Client, data::AbstractDict)
    logmsg(c, WARN, "Received INVALID_SESSION"; resumable=data["d"])
    sleep(rand(1:5))
    reconnect(c; resume=data["d"])
end

function hello(c::Client, data::AbstractDict)
    c.heartbeat_interval = data["d"]["heartbeat_interval"]
end

heartbeat_ack(c::Client, ::AbstractDict) = c.last_ack = now()

# Gateway opcodes => handler function.
const HANDLERS = Dict(
    0   => dispatch,
    1   => heartbeat,
    7   => reconnect,
    9   => invalid_session,
    10  => hello,
    11  => heartbeat_ack,
)

# Error handling.

const CLOSE_CODES = Dict(
    1000 => :NORMAL,
    4000 => :UNKNOWN_ERROR,
    4001 => :UNKNOWN_OPCODE,
    4002 => :DECODE_ERROR,
    4003 => :NOT_AUTHENTICATED,
    4004 => :AUTHENTICATION_FAILED,
    4005 => :ALREADY_AUTHENTICATED,
    4007 => :INVALID_SEQ,
    4008 => :RATE_LIMITED,
    4009 => :SESSION_TIMEOUT,
    4010 => :INVALID_SHARD,
    4011 => :SHARDING_REQUIRED
)

function handle_read_error(c::Client, e::Exception)
    logmsg(c, DEBUG, "Handling a $(typeof(e))"; e=e, conn=c.conn.v)
    c.ready || return
    if isa(e, WebSocketClosedError)
        handle_close(c, e)
    else
        logmsg(c, ERROR, sprint(showerror, e))
        isopen(c) || reconnect(c; resume=true)
    end
end

function handle_close(c::Client, e::WebSocketClosedError)
    code = closecode(e)
    code === nothing && return reconnect(c; resume=true)  # Network error, etc.
    err = get(CLOSE_CODES, code, :UNKNOWN_ERROR)
    if err !== :NORMAL
        logmsg(c, WARN, "WebSocket connnection was closed"; code=code, reason=err)
    end

    if err === :NORMAL
        close(c)
    elseif err === :UNKNOWN_ERROR
        reconnect(c)
    elseif err === :UNKNOWN_OPCODE  # Probably a library bug.
        reconnect(c)
    elseif err === :DECODE_ERROR  # Probably a library bug.
        reconnect(c)
    elseif err === :NOT_AUTHENTICATED  # Probably a library bug.
        reconnect(c)
    elseif err === :AUTHENTICATION_FAILED
        close(c)
    elseif err === :ALREADY_AUTHENTICATED  # Probably a library bug.
        reconnect(c)
    elseif err === :INVALID_SEQ  # Probably a library bug.
        reconnect(c)
    elseif err === :RATE_LIMITED  # Probably a library bug.
        reconnect(c)
    elseif err === :SESSION_TIMEOUT
        reconnect(c)
    elseif err === :INVALID_SHARD
        close(c)
    elseif err === :SHARDING_REQUIRED
        close(c)
    end
end

# Helpers.

function readjson(io)
    return try
        JSON.parse(String(read(io))), nothing
    catch e
        nothing, e
    end
end

writejson(io, body) = writeguarded(io, json(body))

function closecode(e::WebSocketClosedError)
    m = match(r"OPCODE_CLOSE (\d+)", e.message)
    return m === nothing ? nothing : parse(Int, String(first(m.captures)))
end

function locked(f::Function, l::Threads.AbstractLock)
    lock(l)
    try
        f()
    finally
        unlock(l)
    end
end

insert_or_update(d, k, v) = d[k] = haskey(d, k) ? merge(d[k], v) : v

@enum LogLevel DEBUG INFO WARN ERROR

function logmsg(c::Client, level::LogLevel, msg::AbstractString; kwargs...)
    msg = c.shards > 1 ? "[Shard $(c.shard)] $msg" : msg
    msg = "$(now()) $msg"

    if level === DEBUG
        @debug msg kwargs...
    elseif level === INFO
        @info msg kwargs...
    elseif level === WARN
        @warn msg kwargs...
    elseif level == ERROR
        @error msg kwargs...
    else
        error("Unknown log level $level")
    end
end
