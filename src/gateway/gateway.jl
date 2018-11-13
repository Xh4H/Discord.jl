export request_guild_members,
    update_voice_status,
    update_status,
    update_presence

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

struct Empty <: Exception end

# Connection.

"""
    open(c::Client; delay::Period=Second(7))

Connect a [`Client`](@ref) to the Discord gateway.

The `delay` keyword is the time between shards connecting. It can be increased from its
default if you are frequently experiencing invalid sessions upon connection.
"""
function Base.open(c::Client; resume::Bool=false, delay::Period=Second(7))
    isopen(c) && throw(ArgumentError("Client is already connected"))
    c.ready = false

    # Clients can only identify once per 5 seconds.
    resume || sleep(c.shard * delay)

    @debug "Requesting gateway URL" logkws(c; conn=undef)...
    resp = try
        HTTP.get("$DISCORD_API/v$(c.version)/gateway")
    catch e
        @error catchmsg(e) logkws(c; conn=undef)...
        rethrow(e)
    end

    data = JSON.parse(String(resp.body))
    url = "$(data["url"])?v=$(c.version)&encoding=json"
    v = isdefined(c, :conn) ? c.conn.v + 1 : 1
    @debug "Connecting to gateway" logkws(c; conn=v, url=url)...
    c.conn = Conn(opentrick(HTTP.WebSockets.open, url), v)

    @debug "Receiving HELLO" logkws(c)...
    data, e = readjson(c.conn.io)
    e === nothing || throw(e)
    op = get(OPCODES, data["op"], data["op"])
    op === :HELLO || error("Expected opcode HELLO, received $op")
    hello(c, data)

    data = if resume
        Dict("op" => 6, "d" => Dict(
            "token" => c.token,
            "session_id" => c.state.session_id,
            "seq" => c.hb_seq,
        ))
    else
        d = Dict("op" => 2, "s" => c.hb_seq, "d" => Dict(
            "token" => c.token,
            "properties" => conn_properties,
        ))
        if !isempty(c.state.login_presence)
            d["d"]["presence"] = c.state.login_presence
        end
        if c.shards > 1
            d["d"]["shard"] = [c.shard, c.shards]
        end
        d
    end

    op = resume ? :RESUME : :IDENTIFY
    @debug "Writing $op" logkws(c)...
    writejson(c.conn.io, data) === nothing || error("Writing $op failed")

    @debug "Starting background maintenance tasks" logkws(c)...
    @async heartbeat_loop(c)
    @async read_loop(c)

    c.ready = true
end

"""
    isopen(c::Client) -> Bool

Determine whether the [`Client`](@ref) is connected to the gateway.
"""
Base.isopen(c::Client) = c.ready && isdefined(c, :conn) && isopen(c.conn.io)

"""
    close(c::Client)

Disconnect the [`Client`](@ref) from the Discord gateway.
"""
function Base.close(c::Client; statuscode::Int=1000, zombie::Bool=false)
    c.ready = false
    if isdefined(c, :conn)
        if zombie
            # It seems that Discord doesn't send a closing frame for zombie connections
            # (which makes sense). However, close waits for one forever (see HTTP.jl#350).
            @async close(c.conn.io; statuscode=statuscode)
            sleep(1)
        else
            close(c.conn.io; statuscode=statuscode)
        end
    end
end

"""
    wait(c::Client)

Wait for an open [`Client`](@ref) to close.
"""
function Base.wait(c::Client)
    while isopen(c)
        wait(c.conn.io.cond)
        # This is an arbitrary amount of time to wait,
        # but we want to wait long enough to potentially reconnect.
        sleep(30)
    end
end

# Gateway commands.

"""
    request_guild_members(
        c::Client,
        guilds::Union{Integer, Vector{<:Integer};
        query::AbstractString="",
        limit::Int=0,
    ) -> Bool

Request offline guild members of one or more [`Guild`](@ref)s. [`GuildMembersChunk`](@ref)
events are sent by the gateway in response.
More details [here](https://discordapp.com/developers/docs/topics/gateway#request-guild-members).
"""
function request_guild_members(
    c::Client,
    guild::Integer;
    query::AbstractString="",
    limit::Int=0,
)
    return request_guild_members(c, [guild]; query=query, limit=limit)
end

function request_guild_members(
    c::Client,
    guilds::Vector{<:Integer};
    query::AbstractString="",
    limit::Int=0,
)
    return isdefined(c, :conn) && writejson(c.conn.io, Dict("op" => 8, "d" => Dict(
        "guild_id" => guilds,
        "query" => query,
        "limit" => limit,
    ))) === nothing
end

"""
    update_voice_state(
        c::Client,
        guild::Integer,
        channel::Union{Integer, Nothing},
        mute::Bool,
        deaf::Bool,
    ) -> Bool

Join, move, or disconnect from a voice channel. A [`VoiceStateUpdate`](@ref) event is sent
by the gateway in response.
More details [here](https://discordapp.com/developers/docs/topics/gateway#update-voice-state).
"""
function update_voice_state(
    c::Client,
    guild::Integer,
    channel::Union{Integer, Nothing},
    mute::Bool,
    deaf::Bool,
)
    return isdefined(c, :conn) && writejson(c.conn.io, Dict("op" => 4, "d" => Dict(
        "guild_id" => guild,
        "channel_id" => channel,
        "self_mute" => mute,
        "self_deaf" => deaf,
    ))) === nothing
end

"""
    update_status(
        c::Client,
        since::Union{Int, Nothing},
        activity::Union{Activity, Nothing},
        status::Union{PresenceStatus, AbstractString},
        afk::Bool,
    ) -> Bool

Indicate a presence or status update. A [`PresenceUpdate`](@ref) event is sent by the
gateway in response.
More details [here](https://discordapp.com/developers/docs/topics/gateway#update-status).
"""
function update_status(
    c::Client,
    since::Union{Int, Nothing},
    game::Union{Dict, NamedTuple, Activity, Nothing},
    status::Union{PresenceStatus, AbstractString},
    afk::Bool,
)
    since != Nothing && (c.state.login_presence["since"] = since)
    game != Nothing && (c.state.login_presence["game"] = game)
    c.state.login_presence["status"] = since
    c.state.login_presence["afk"] = since

    return isdefined(c, :conn) && writejson(c.conn.io, Dict("op" => 3, "d" => Dict(
        "since" => since,
        "game" => game,
        "status" => status,
        "afk" => afk,
    ))) === nothing
end

# Client maintenance.

# Continuously send the heartbeat.
function heartbeat_loop(c::Client)
    v = c.conn.v
    try
        sleep(rand(1:round(Int, c.hb_interval / 1000)))
        heartbeat(c) || (isopen(c) && @error "Writing HEARTBEAT failed" logkws(c)...)

        while c.conn.v == v && isopen(c)
            sleep(c.hb_interval / 1000)
            if c.last_hb > c.last_ack && isopen(c) && c.conn.v == v
                @debug "Encountered zombie connection" logkws(c)...
                reconnect(c; zombie=true)
            elseif !heartbeat(c) && c.conn.v == v && isopen(c)
                @error "Writing HEARTBEAT failed" logkws(c)...
            end
        end
        @debug "Heartbeat loop exited" logkws(c; conn=v)...
    catch e
        @error "Heartbeat loop exited unexpectedly:\n$(catchmsg(e))" logkws(c; conn=v)...
    end
end

# Continuously read and respond to messages.
function read_loop(c::Client)
    v = c.conn.v
    try
        while c.conn.v == v && isopen(c)
            data, e = readjson(c.conn.io)
            if e !== nothing
                if c.conn.v == v
                    handle_read_exception(c, e)
                else
                    @debug "Read failed, but the connection is outdated" logkws(c; error=e)...
                end
            elseif haskey(HANDLERS, data["op"])
                HANDLERS[data["op"]](c, data)
            else
                @warn "Unkown opcode" logkws(c; op=data["op"])...
            end
        end
        @debug "Read loop exited" logkws(c; conn=v)...
    catch e
        @error "Read loop exited unexpectedly:\n$(catchmsg(e))" logkws(c; conn=v)...
    end
end

# Event handlers.

# Dispatch an event to its handlers.
function dispatch(c::Client, data::Dict)
    c.hb_seq = data["s"]

    T = get(EVENT_TYPES, data["t"], UnknownEvent)

    handlers = allhandlers(c, T)
    # If there are no handlers to call, don't bother parsing the event.
    isempty(handlers) && return

    evt = if T === UnknownEvent
        UnknownEvent(data)
    else
        val, e = tryparse(c, T, data["d"])
        if e === nothing
            val
        else
            T = UnknownEvent
            UnknownEvent(data)
        end
    end

    for (tag, handler) in handlers
        @async try
            handler.f(c, evt)
        catch e
            @error catchmsg(e) logkws(c; event=T, handler=tag)...
            push!(c.state.errors, evt)
        finally
            # TODO: There are race conditions here.
            if handler.expiry isa Int && handler.expiry != -1
                handler.expiry -= 1
            end
        end
    end
end

# Send a heartbeat.
function heartbeat(c::Client, ::Dict=Dict())
    e = writejson(c.conn.io, Dict("op" => 1, "d" => c.hb_seq))
    e === nothing && (c.last_hb = now())
    return e === nothing
end

# Reconnect to the gateway.
function reconnect(c::Client, ::Dict=Dict(); resume::Bool=true, zombie::Bool=false)
    @info "Reconnecting" logkws(c; resume=resume, zombie=zombie)...
    close(c; zombie=zombie, statuscode=resume ? 4000 : 1000)
    open(c; resume=resume)
end

# React to an invalid session.
function invalid_session(c::Client, data::Dict)
    @warn "Received INVALID_SESSION" logkws(c; resumable=data["d"])...
    sleep(rand(1:5))
    reconnect(c; resume=data["d"])
end

# React to a hello message.
hello(c::Client, data::Dict) = c.hb_interval = data["d"]["heartbeat_interval"]

# React to a heartbeack ack.
heartbeat_ack(c::Client, ::Dict) = c.last_ack = now()

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
    4001 => :UNKNOWN_OPCODE,         # Probably a library bug.
    4002 => :DECODE_ERROR,           # Probably a library bug.
    4003 => :NOT_AUTHENTICATED,      # Probably a library bug.
    4004 => :AUTHENTICATION_FAILED,
    4005 => :ALREADY_AUTHENTICATED,  # Probably a library bug.
    4007 => :INVALID_SEQ,            # Probably a library bug.
    4008 => :RATE_LIMITED,           # Probably a library bug.
    4009 => :SESSION_TIMEOUT,
    4010 => :INVALID_SHARD,
    4011 => :SHARDING_REQUIRED,
)

# Deal with an error from reading a message.
function handle_read_exception(c::Client, e::Exception)
    @debug "Handling a $(typeof(e))" logkws(c; error=e)...
    c.ready && handle_specific_exception(c, e)
end

handle_specific_exception(::Client, ::Empty) = nothing
handle_specific_exception(c::Client, ::EOFError) = reconnect(c)
function handle_specific_exception(c::Client, e::HTTP.WebSockets.WebSocketError)
    err = get(CLOSE_CODES, status, :UNKNOWN_ERROR)
    if err === :NORMAL
        close(c)
    elseif err === :AUTHENTICATION_FAILED
        @error "Authentication failed" logkws(c)...
        close(c)
    elseif err === :INVALID_SHARD
        @error "Invalid shard" logkws(c)...
        close(c)
    elseif err === :SHARDING_REQUIRED
        @error "Sharding required" logkws(c)...
        close(c)
    else
        @debug "Gateway connection was closed" logkws(c; code=status, error=err)...
        reconnect(c)
    end
end
function handle_specific_exception(c::Client, e::Exception)
    @error sprint(showerror, e) logkws(c)...
    isopen(c) || reconnect(c)
end

# Helpers.

# Read a JSON message.
function readjson(io)
    return try
        data = readavailable(io)
        if isempty(data)
            nothing, Empty()
        else
            JSON.parse(String(data)), nothing
        end
    catch e
        nothing, e
    end
end

# Write a JSON message.
function writejson(io, body)
    return try
        write(io, json(body))
        nothing
    catch e
        e
    end
end
