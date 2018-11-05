export request_guild_members,
    update_voice_status,
    update_status


const conn_properties = Dict(
    "\$os"      => string(Sys.KERNEL),
    "\$browser" => "Discord.jl",
    "\$device"  => "Discord.jl",
)

const EMPTY = ErrorException("Empty")

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

# Connection.

"""
    open(c::Client; delay::Period=Second(7))

Connect to the Discord gateway and begin responding to events.

The `delay` keyword is the time between shards connecting. It can be increased from its
default if you are frequently experiencing invalid sessions upon connection.
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
    v = isdefined(c, :conn) ? c.conn.v + 1 : 1
    c.conn = Conn(opentrick(HTTP.WebSockets.open, url), v)

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
            "properties" => conn_properties,
        ))

        if c.shards > 1
            d["d"]["shard"] = [c.shard, c.shards]
        end
        d
    end

    op = resume ? :RESUME : :IDENTIFY
    logmsg(c, DEBUG, "Writing $op"; conn=c.conn.v)
    writejson(c.conn.io, data) === nothing || error("Writing $op failed")

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
    close(c::Client)

Disconnect from the Discord gateway.
"""
function Base.close(c::Client; code::Int=1000)
    c.ready = false
    isdefined(c, :conn) && close(c.conn.io; statuscode=code)
end

"""
    wait(c::Client)

Wait for an open client to close.
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
        guild_id::Union{Integer, Vector{<:Integer};
        query::AbstractString="",
        limit::Int=0,
    ) -> Bool

Request offline guild members of one or more guilds. [`GuildMembersChunk`](@ref) events are
sent by the gateway in response.
More details [here](https://discordapp.com/developers/docs/topics/gateway#request-guild-members).
"""
function request_guild_members(
    c::Client,
    guild_id::Integer;
    query::AbstractString="",
    limit::Int=0,
)
    return request_guild_members(c, [guild_id]; query=query, limit=limit)
end

function request_guild_members(
    c::Client,
    guild_id::Vector{<:Integer};
    query::AbstractString="",
    limit::Int=0,
)
    return writejson(c.conn.io, Dict("op" => 8, "d" => Dict(
        "guild_id" => guild_id,
        "query" => query,
        "limit" => limit,
    ))) === nothing
end

"""
    update_voice_state(
        c::Client,
        guild_id::Integer,
        channel_id::Union{Integer, Nothing},
        self_mute::Bool,
        self_deaf::Bool,
    ) -> Bool

Join, move, or disconnect from a voice channel. A [`VoiceStateUpdate`](@ref) event is sent
by the gateway in response.
More details [here](https://discordapp.com/developers/docs/topics/gateway#update-voice-state).
"""
function update_voice_state(
    c::Client,
    guild_id::Integer,
    channel_id::Union{Integer, Nothing},
    self_mute::Bool,
    self_deaf::Bool,
)
    return writejson(c.conn.io, Dict("op" => 4, "d" => Dict(
        "guild_id" => guild_id,
        "channel_id" => channel_id,
        "self_mute" => self_mute,
        "self_deaf" => self_deaf,
    ))) === nothing
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
    ))) === nothing
end

# Client maintenance.

function heartbeat_loop(c::Client)
    v = c.conn.v
    try
        sleep(rand(1:round(Int, c.heartbeat_interval / 1000)))
        heartbeat(c) || logmsg(c, ERROR, "Writing HEARTBEAT failed"; conn=v)

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
    catch e
        logmsg(c, ERROR, "Heartbeat loop exited unexpectedly:\n$(catchmsg(e))"; conn=v)
    end
end

function read_loop(c::Client)
    v = c.conn.v
    try
        while c.conn.v == v && isopen(c)
            data, e = readjson(c.conn.io)
            if e !== nothing
                if e == EMPTY
                    continue
                elseif c.conn.v == v
                    handle_read_error(c, e)
                else
                    logmsg(c, DEBUG, "Read failed, but the connection is outdated"; conn=v, e=e)
                end
            elseif haskey(HANDLERS, data["op"])
                HANDLERS[data["op"]](c, data)
            else
                logmsg(c, WARN, "Unkown opcode"; op=data["op"])
            end
        end
        logmsg(c, DEBUG, "Read loop exited"; conn=v)
    catch e
        logmsg(c, ERROR, "Read loop exited unexpectedly:\n$(catchmsg(e))"; conn=v)
    end
end

# Event handlers.

function dispatch(c::Client, data::Dict)
    c.heartbeat_seq = data["s"]

    T = get(EVENT_TYPES, data["t"], UnknownEvent)

    hs = allhandlers(c, T)
    # If there are no handlers to call, don't bother parsing the event.
    isempty(hs) && return

    evt = begin
        if T === UnknownEvent
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
    end

    for h in hs
        @async try
            h.f(c, evt)
        catch e
            logmsg(c, ERROR, catchmsg(e); event=T, handler=h.tag)
            push!(c.state.errors, evt)
        finally
            if h.expiry isa Int && h.expiry != -1
                h.expiry -= 1
            end
        end
    end
end

function heartbeat(c::Client, ::Dict=Dict())
    e = writejson(c.conn.io, Dict("op" => 1, "d" => c.heartbeat_seq))
    if e === nothing
        c.last_heartbeat = now()
    end
    return e === nothing
end

function reconnect(c::Client, ::Dict=Dict(); resume::Bool=true)
    logmsg(c, INFO, "Reconnecting"; resume=resume)
    close(c; code=resume ? 4000 : 1000)
    open(c; resume=resume)
end

function invalid_session(c::Client, data::Dict)
    logmsg(c, WARN, "Received INVALID_SESSION"; resumable=data["d"])
    sleep(rand(1:5))
    reconnect(c; resume=data["d"])
end

hello(c::Client, data::Dict) = c.heartbeat_interval = data["d"]["heartbeat_interval"]

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
    if e isa HTTP.WebSockets.WebSocketError
        handle_close(c, e.status)
    else
        logmsg(c, ERROR, sprint(showerror, e))
        isopen(c) || reconnect(c; resume=true)
    end
end

function handle_close(c::Client, status::Integer)
    err = get(CLOSE_CODES, status, :UNKNOWN_ERROR)
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
        data = readavailable(io)
        if isempty(data)
            nothing, EMPTY
        else
            JSON.parse(String(data)), nothing
        end
    catch e
        nothing, e
    end
end

function writejson(io, body)
    return try
        write(io, json(body))
        nothing
    catch e
        e
    end
end
