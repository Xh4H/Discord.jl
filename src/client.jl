export LIMIT_IGNORE,
    LIMIT_WAIT,
    Client,
    me,
    add_handler!,
    delete_handler!,
    clear_handlers!,
    add_command!,
    request_guild_members,
    update_voice_status,
    update_status

# Properties for gateway connections.
const conn_properties = Dict(
    "\$os"      => String(Sys.KERNEL),
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

"""
Passed as a keyword argument to [`Client`](@ref) to determine the client's behaviour when
it hits a rate limit. If set to `LIMIT_IGNORE`, a [`Response`](@ref) is returned
immediately with `rate_limited` set to `true`. If set to `LIMIT_WAIT`, the client blocks
until the rate limit resets, then retries the request.
"""
@enum OnLimit LIMIT_IGNORE LIMIT_WAIT

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
    Client(
        token::String;
        on_limit::OnLimit=LIMIT_IGNORE,
        ttl::Period=Hour(1),
        version::Int=$API_VERSION,
     ) -> Client

A Discord bot. `Client`s can connect to the gateway, respond to events, and make REST API
calls to perform actions such as sending/deleting messages, kicking/banning users, etc.

To get a bot token, head [here](https://discordapp.com/developers/applications) to create a
new application. Once you've created a bot user, you will have access to its token.

# Keywords
- `on_limit::OnLimit=LIMIT_IGNORE`: Client's behaviour when it hits a rate limit (see "Rate
  Limiting" below for more details).
- `ttl::Period=Hour(1)` Amount of time that cache entries are kept (see "Caching" below for
  more details).
- `version::Int=$API_VERSION`: Version of the Discord API to use. Using anything but
  $API_VERSION is not officially supported by the Discord.jl developers.

# Caching
By default, most data that comes from Discord is cached for later use. However, to avoid
memory leakage, it's deleted after some time (determined by the `ttl` keyword). Although
it's not recommended, you can also disable caching of certain data by clearing default
handlers for relevant event types with [`clear_handlers!`](@ref). For example, if you
wanted to avoid caching any messages, you would clear handlers for [`MessageCreate`](@ref)
and [`MessageUpdate`](@ref) events.

# Rate Limiting
Discord enforces rate limits on usage of its REST API. This  means you can  only send so
many messages in a given period, and so on. To customize the client's behaviour when
encountering rate limits, use the `on_limit` keyword and see [`OnLimit`](@ref).

# Sharding
Sharding is handled automatically: The number of available processes is the number of
shards that are created. See the
[sharding example](https://github.com/PurgePJ/Discord.jl/blob/master/examples/sharding.jl)
for more details.
"""
mutable struct Client
    token::String             # Bot token, always with a leading "Bot ".
    heartbeat_interval::Int   # Milliseconds between heartbeats.
    heartbeat_seq::Union{Int, Nothing}  # Sequence value sent by Discord for resuming.
    last_heartbeat::DateTime  # Last heartbeat send.
    last_ack::DateTime        # Last heartbeat ack.
    ttl::Period               # Cache lifetime.
    version::Int              # Discord API version.
    state::State              # Client state, cached data, etc.
    shards::Int               # Number of shards in use.
    shard::Int                # Client's shard index.
    limiter::Limiter          # Rate limiter.
    on_limit::OnLimit         # Rate limit behaviour.
    handlers::Dict{Type{<:AbstractEvent}, Set{Handler}}  # Event handlers.
    closed::Bool              # Client is closed and will not reconnect.
    conn::Conn                # WebSocket connection.

    function Client(
        token::String;
        on_limit::OnLimit=LIMIT_IGNORE,
        ttl::Period=Hour(1),
        version::Int=API_VERSION,
    )
        token = startswith(token, "Bot ") ? token : "Bot $token"
        return new(
            token,                            # token
            0,                                # heartbeat_interval
            nothing,                          # heartbeat_seq
            DateTime(0),                      # last_heartbeat
            DateTime(0),                      # last_ack
            ttl,                              # ttl
            version,                          # version
            State(ttl),                       # state
            nprocs(),                         # shards
            myid() - 1,                       # shard
            Limiter(),                        # limiter
            on_limit,                         # on_limit
            copy(DEFAULT_DISPATCH_HANDLERS),  # handlers
            true,                             # closed
            # conn left undef, it gets assigned in open.
        )
    end
end

"""
    open(c::Client)

Connect to the Discord gateway and begin responding to events.
"""
function Base.open(c::Client; resume::Bool=false)
    isopen(c) && error("Client is already open")

    # For some reason I'm getting invalid sessions (opcode 9) when non-zero shards connect
    # before shard 0 or at the same time. This seems to fix it.
    c.shard > 0 && sleep(5)

    logmsg(c, DEBUG, "Requesting gateway URL")
    resp = HTTP.get("$DISCORD_API/v$(c.version)/gateway")
    data = JSON.parse(String(resp.body))
    url = "$(data["url"])?v=$(c.version)&encoding=json"
    logmsg(c, DEBUG, "Connecting to gateway"; url=url)
    c.conn = Conn(opentrick(WebSockets.open, url), isdefined(c, :conn) ? c.conn.v + 1 : 1)

    logmsg(c, DEBUG, "receiving HELLO")
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
                "properties" => conn_properties,
        ))

        if c.shards > 1
            d["d"]["shard"] = [c.shard, c.shards]
        end
        d
    end

    op = resume ? :RESUME : :IDENTIFY
    logmsg(c, DEBUG, "Writing $op")
    writejson(c.conn.io, data) || error("Writing $op failed")

    logmsg(c, DEBUG, "Starting background maintenance tasks")
    @async heartbeat_loop(c)
    @async read_loop(c)

    c.closed = false
    logmsg(c, INFO, "Logged in")
end

"""
    isopen(c::Client) -> Bool

Determine whether the client is connected to the gateway.
"""
Base.isopen(c::Client) = !c.closed && isdefined(c, :conn) && isopen(c.conn.io)

"""
    Base.close(c::Client)

Disconnect from the Discord gateway.
"""
function Base.close(c::Client; permanent::Bool=true, statusnumber::Int=1000)
    if permanent
        logmsg(c, INFO, "Logging out")
        c.closed = true
    end
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

Add a handler for an event type.
The handler should be a function which takes two arguments: A [`Client`](@ref) and an
[`AbstractEvent`](@ref) (or a subtype).
The handler is appended the event's current handlers.

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
    delete_handler!(c::Client, evt::Type{<:AbstractEvent}, tag::Symbol)

Delete a single handler by event type and tag.
"""
function delete_handler!(c::Client, evt::Type{<:AbstractEvent}, tag::Symbol)
    filter!(h -> h.tag !== tag, get(c.handlers, evt, []))
end

"""
    clear_handlers!(c::Client, evt::Type{<:AbstractEvent})

Remove all handlers for an event type. Using this is generally not recommended
because it also clears default handlers which maintain the client state. Instead, it's
preferred add handlers with specific tags and delete them with [`delete_handler!`](@ref).
"""
clear_handlers!(c::Client, event::Type{<:AbstractEvent}) = delete!(c.handlers, event)

"""
    add_command!(
        c::Client,
        prefix::AbstractString,
        func::Function;
        tag::Symbol=gensym(),
        expiry::Union{Int, Period}=-1,
    )

Add a text command handler. The handler function should take two arguments: A
[`Client`](@ref) and a [`Message`](@ref). The keyword arguments are identical to
[`add_handler!`](@ref).
"""
function add_command!(
    c::Client,
    prefix::AbstractString,
    func::Function;
    tag::Symbol=gensym(),
    expiry::Union{Int, Period}=-1,
)
    function handler(c::Client, e::MessageCreate)
        e.message.author.id == me(c).id && return
        startswith(e.message.content, prefix) || return
        func(c, e.message)
    end

    add_handler!(c, MessageCreate, handler; tag=tag, expiry=expiry)
end

# Client maintenance.

function heartbeat_loop(c::Client)
    v = c.conn.v
    while c.conn.v == v && isopen(c)
        if c.last_heartbeat > c.last_ack
            logmsg(c, DEBUG, "Encountered zombie connection")
            reconnect(c; resume=true, statusnumber=1001)
        elseif !heartbeat(c) && c.conn.v == v && isopen(c)
            logmsg(c, ERROR, "Writing HEARTBEAT failed")
        elseif c.conn.v == v && isopen(c)
            sleep(c.heartbeat_interval / 1000)
        end
    end
    logmsg(c, DEBUG, "Heartbeat loop $v exited")
end

function read_loop(c::Client)
    v = c.conn.v
    while c.conn.v == v && isopen(c)
        data, e = readjson(c.conn.io)
        if e !== nothing && c.conn.v == v
            handle_read_error(c, e)
        elseif e !== nothing
            logmsg(c, DEBUG, "Read failed, but the connection is outdated"; e=e)
        elseif haskey(HANDLERS, data["op"])
            HANDLERS[data["op"]](c, data)
        else
            logmsg(c, WARN, "Unkown opcode"; op=data["op"])
        end
    end
    logmsg(c, DEBUG, "Read loop $v exited")
end

# Event handlers.

function dispatch(c::Client, data::AbstractDict)
    c.heartbeat_seq = data["s"]
    evt = try
        AbstractEvent(data)
    catch e
        err = sprint(showerror, e) * sprint(Base.show_backtrace, catch_backtrace())
        logmsg(c, ERROR, err; type=data["t"])
        UnknownEvent(data)
    end
    push!(c.state.events, evt)

    catchalls = collect(get(c.handlers, AbstractEvent, []))
    specifics = collect(get(c.handlers, typeof(evt), []))
    for handler in [catchalls; specifics]
        @async try
            handler.f(c, evt)
        catch e
            err = sprint(showerror, e) * sprint(Base.show_backtrace, catch_backtrace())
            logmsg(c, ERROR, err; event=typeof(evt), handler=handler.tag)
        finally
            if handler.remaining != -1
                handler.remaining -= 1
            end
        end
    end

    filter!(!isexpired, get(c.handlers, AbstractEvent, []))
    filter!(!isexpired, get(c.handlers, typeof(evt), []))
end

function heartbeat(c::Client, ::AbstractDict=Dict())
    ok = writejson(c.conn.io, Dict("op" => 1, "d" => c.heartbeat_seq))
    if ok
        c.last_heartbeat = now()
    end
    return ok
end

function reconnect(
    c::Client,
    ::AbstractDict=Dict();
    resume::Bool=false,
    statusnumber::Int=1000,
)
    logmsg(c, INFO, "Reconnecting"; status=statusnumber, resume=resume)
    close(c; permanent=false, statusnumber=statusnumber)
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

# Default dispatch event handlers.
# Note: These are only for opcode 0 (DISPATCH).

handle_ready(c::Client, e::Ready) = ready(c.state, e)

# TODO: Should we be replacing or merging _trace?
handle_resumed(c::Client, e::Resumed) = c.state._trace = e._trace

function handle_channel_create_update(c::Client, e::Union{ChannelCreate, ChannelUpdate})
    c.state.channels[e.channel.id] = e.channel
end

handle_channel_delete(c::Client, e::ChannelDelete) = delete!(c.state.channels, e.channel.id)

function handle_guild_create_update(c::Client, e::Union{GuildCreate, GuildUpdate})
    c.state.guilds[e.guild.id] = e.guild

    for ch in e.guild.channels
        c.state.channels[ch.id] = ch
    end
end

function handle_guild_delete(c::Client, e::GuildDelete)
    delete!(c.state.guilds, e.id)
    delete!(c.state.members, e.id)
    delete!(c.state.presences, e.id)
end

function handle_guild_emojis_update(c::Client, e::GuildEmojisUpdate)
    haskey(c.state.guilds, e.guild_id) || return
    es = c.state.guilds[e.guild_id].emojis
    empty!(es)
    append!(es, e.emojis)
end

function handle_guild_member_add(c::Client, e::GuildMemberAdd)
    if !haskey(c.state.members, e.guild_id)
        c.state.members[e.guild_id] = TTL(c.ttl)
    end
    ms = c.state.members[e.guild_id]
    if ismissing(e.member.user)
        if !haskey(ms, missing)
            ms[missing] = []
        end
        touch(ms, missing)
        push!(ms[missing], e.member)
    else
        ms[e.member.user.id] = e.member
        # Update the user cache as well,
        c.state.users[e.member.user.id] = e.member.user
    end
end

function handle_guild_member_update(c::Client, e::GuildMemberUpdate)
    haskey(c.state.members, e.guild_id) || return
    haskey(c.state.members[e.guild_id], e.user.id) || return

    ms = c.state.members[e.guild_id]
    m = ms[e.user.id]
    ms[e.user.id] = Member(
        e.user,
        e.nick,
        e.roles,
        m.joined_at,
        m.deaf,
        m.mute,
        Dict(),
    )
    # Update the user cache as well.
    c.state.users[e.user.id] = e.user
end

function handle_guild_member_remove(c::Client, e::GuildMemberRemove)
    haskey(c.state.members, e.guild_id) || return
    delete!(c.state.members[e.guild_id], e.user.id)
end

function handle_guild_members_chunk(c::Client, e::GuildMembersChunk)
    if !haskey(c.state.members, e.guild_id)
        c.state.members[e.guild_id] = TTL(c.ttl)
    end

    ms = c.state.members[e.guild_id]

    for m in e.members
        if ismissing(m.user)
            if !haskey(ms, missing)
                ms[missing] = []
            end

            touch(ms, missing)
            push!(ms[missing], m)
        else
            ms[m.user.id] = m
            # Update the user cache as well,
            c.state.users[m.user.id] = m.user
        end
    end
end

function handle_guild_role_create(c::Client, e::GuildRoleCreate)
    haskey(c.state.guilds, e.guild_id) || return
    isa(c.state.guilds[e.guild_id], Guild) || return
    push!(c.state.guilds[e.guild_id].roles, e.role)
end

function handle_guild_role_update(c::Client, e::GuildRoleUpdate)
    haskey(c.state.guilds, e.guild_id) || return
    isa(c.state.guilds[e.guild_id], Guild) || return

    rs = c.state.guilds[e.guild_id].roles
    idx = findfirst(r -> r.id == e.role.id, rs)
    idx === nothing || deleteat!(rs, idx)
    push!(rs, e.role)
end

function handle_guild_role_delete(c::Client, e::GuildRoleDelete)
    haskey(c.state.guilds, e.guild_id) || return
    isa(c.state.guilds[e.guild_id], Guild) || return

    rs = c.state.guilds[e.guild_id].roles
    idx = findfirst(r -> r.id == e.role_id, rs)
    idx === nothing || deleteat!(rs, idx)
end

function handle_message_create_update(c::Client, e::Union{MessageCreate, MessageUpdate})
    c.state.messages[e.message.id] = e.message
end

handle_message_delete(c::Client, e::MessageDelete) = delete!(c.state.messages, e.id)

function handle_message_delete_bulk(c::Client, e::MessageDeleteBulk)
    for id in e.ids
        delete!(c.state.messages, id)
    end
end

function handle_presence_update(c::Client, e::PresenceUpdate)
    if !haskey(c.state.presences, e.presence.guild_id)
        c.state.presences[e.presence.guild_id] = TTL(c.ttl)
    end

    c.state.presences[e.presence.guild_id][e.presence.user.id] = e.presence
end

function handle_message_reaction_add(c::Client, e::MessageReactionAdd)
    haskey(c.state.messages, e.message_id) || return
    # TODO: This has race conditions.
    touch(c.state.messages, e.message_id)

    m = c.state.messages[e.message_id]

    if ismissing(m.reactions)
        m.reactions = [Reaction(1, e.user_id == c.state.user.id, e.emoji, Dict())]
    else
        idx = findfirst(r -> r.emoji.name == e.emoji.name, m.reactions)

        if idx === nothing
            push!(m.reactions, Reaction(1, e.user_id == c.state.user.id, e.emoji, Dict()))
        else
            m.reactions[idx].count += 1
            m.reactions[idx].me |= e.user_id == c.state.user.id
        end
    end
end

function handle_message_reaction_remove(c::Client, e::MessageReactionRemove)
    haskey(c.state.messages, e.message_id) || return
    ismissing(c.state.messages[e.message_id].reactions) && return

    touch(c.state.messages, e.message_id)

    rs = c.state.messages[e.message_id].reactions
    idx = findfirst(r -> r.emoji.name == e.emoji.name, rs)

    if idx !== nothing
        rs[idx].count -= 1
        rs[idx].me &= e.user_id != c.state.user.id
    end
end

function handle_message_reaction_remove_all(c::Client, e::MessageReactionRemoveAll)
    haskey(c.state.messages, e.message_id) || return
    ismissing(c.state.messages[e.message_id].reactions) && return

    touch(c.state.messages, e.message_id)
    empty!(c.state.messages[e.message_id].reactions)
end

const DEFAULT_DISPATCH_HANDLERS = Dict{Type{<:AbstractEvent}, Set{Handler}}(
    Ready                    => Set([Handler(handle_ready)]),
    Resumed                  => Set([Handler(handle_resumed)]),
    ChannelCreate            => Set([Handler(handle_channel_create_update)]),
    ChannelUpdate            => Set([Handler(handle_channel_create_update)]),
    ChannelDelete            => Set([Handler(handle_channel_delete)]),
    GuildCreate              => Set([Handler(handle_guild_create_update)]),
    GuildUpdate              => Set([Handler(handle_guild_create_update)]),
    GuildDelete              => Set([Handler(handle_guild_delete)]),
    GuildEmojisUpdate        => Set([Handler(handle_guild_emojis_update)]),
    GuildMemberAdd           => Set([Handler(handle_guild_member_add)]),
    GuildMemberUpdate        => Set([Handler(handle_guild_member_update)]),
    GuildMemberRemove        => Set([Handler(handle_guild_member_remove)]),
    GuildMembersChunk        => Set([Handler(handle_guild_members_chunk)]),
    GuildRoleCreate          => Set([Handler(handle_guild_role_create)]),
    GuildRoleUpdate          => Set([Handler(handle_guild_role_update)]),
    GuildRoleDelete          => Set([Handler(handle_guild_role_delete)]),
    MessageCreate            => Set([Handler(handle_message_create_update)]),
    MessageUpdate            => Set([Handler(handle_message_create_update)]),
    MessageDelete            => Set([Handler(handle_message_delete)]),
    MessageDeleteBulk        => Set([Handler(handle_message_delete_bulk)]),
    MessageReactionAdd       => Set([Handler(handle_message_reaction_add)]),
    MessageReactionRemove    => Set([Handler(handle_message_reaction_remove)]),
    MessageReactionRemoveAll => Set([Handler(handle_message_reaction_remove_all)]),
    PresenceUpdate           => Set([Handler(handle_presence_update)]),
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
    4011 => :SHARDING_REQUIRED,
)

function handle_read_error(c::Client, e::Exception)
    logmsg(c, DEBUG, "Handling a $(typeof(e))"; e=e, conn=c.conn.v)
    c.closed && return
    if isa(e, WebSocketClosedError)
        handle_close(c, e)
    else
        logmsg(c, ERROR, sprint(showerror, e))
    end
end

function handle_close(c::Client, e::WebSocketClosedError)
    code = closecode(e)
    code === nothing && throw(e)
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
        json = read(io)
        JSON.parse(String(json)), nothing
    catch e
        nothing, e
    end
end

writejson(io, body) = writeguarded(io, json(body))

function closecode(e::WebSocketClosedError)
    m = match(r"OPCODE_CLOSE (\d+)", e.message)
    return match === nothing ? nothing : parse(Int, String(first(m.captures)))
end

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
