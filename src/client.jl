export Client,
    state,
    me,
    add_handler!,
    clear_handlers!

# Properties for gateway connections.
const conn_properties = Dict(
    "\$os"      => String(Sys.KERNEL),
    "\$browser" => "Julicord",
    "\$device"  => "Julicord",
)

const OPCODES = Dict(
    0 =>    :DISPATCH,
    1 =>    :HEARTBEAT,
    2 =>    :IDENTIFY,
    3 =>    :STATUS_UPDATE,
    4 =>    :VOICE_STATUS_UPDATE,
    6 =>    :RESUME,
    7 =>    :RECONNECT,
    8 =>    :REQUEST_GUILD_MEMBERS,
    9 =>    :INVALID_SESSION,
    10 =>   :HELLO,
    11 =>   :HEARTBEAT_ACK,
)

"""
    Client(token::String) -> Client

A Discord bot.

# Arguments
* `token::String`: The bot's token.
"""
mutable struct Client
    token::String
    heartbeat_interval::Int
    heartbeat_seq::Union{Int, Nothing}
    last_heartbeat::DateTime
    last_ack::DateTime
    state::Cache
    handlers::Dict{Type{<:AbstractEvent}, Vector{Function}}
    hb_chan::Channel  # Channel to stop the maintain_heartbeat coroutine upon disconnnect.
    rl_chan::Channel  # Same thing for read_loop.
    conn::OpenTrick.IOWrapper

    function Client(token::String)
        token = startswith(token, "Bot ") ? token : "Bot $token"

        return new(
            token,             # token
            0,                 # heartbeat_interval
            nothing,           # heartbeat_seq
            unix2datetime(0),  # last_heartbeat
            unix2datetime(0),  # last_ack
            Cache(),           # state
            Dict(),            # handlers
            Channel(0),        # hb_chan
            Channel(0),        # rl_chan
            # conn left undef, it gets assigned in open.
        )
    end
end

"""
    open(c::Client)

Log in to the Discord gateway and begin reading events.
"""
function Base.open(c::Client; resume::Bool=false)
    isopen(c) && error("Client is already open")

    # Get the gateway URL and connect to it.
    resp = HTTP.get("$DISCORD_API/gateway")
    d = JSON.parse(String(resp.body))
    url = "$(d["url"])?v=$API_VERSION&encoding=json"
    conn = opentrick(WebSockets.open, url)
    c.conn = conn

    # Receive HELLO.
    data, e = readjson(conn)
    e === nothing || throw(e)
    op = get(OPCODES, data["op"], data["op"])
    op === :HELLO || error("expected opcode HELLO, received $op")
    hello(c, data)

    # Write the first heartbeat.
    heartbeat(c) || error("writing HEARTBEAT failed")

    # Read the heartbeat ack.
    data, e = readjson(conn)
    e === nothing || throw(e)
    op = get(OPCODES, data["op"], data["op"])
    op === :HEARTBEAT_ACK || error("expected opcode HEARTBEAT_ACK, received $op")
    heartbeat_ack(c, data)

    if resume
        # Write the RESUME.
        writejson(conn, Dict(
            "op" => 6,
            "d" => Dict(
                "token" => c.token,
                "session_id" => get(c.state.state, "session_id", ""),
                "seq" => c.heartbeat_seq,
            ),
        )) || error("writing RESUME failed")
    else
        # Write the IDENTIFY.
        writejson(conn, Dict(
            "op" => 2,
            "d" => Dict(
                "token" => c.token,
                "properties" => conn_properties,
            ),
        )) || error("writing IDENTIFY failed")

        # Read the READY message, and assign initial state.
        data, e = readjson(conn)
        e === nothing || throw(e)
        op = get(OPCODES, data["op"], data["op"])
        op === :DISPATCH || error("expected opcode DISPATCH, received $op")
        data["t"] == "READY" || error("expected event type READY, received $(data["t"])")
        merge!(c.state.state, data["d"])

        for g in get(data["d"], "guilds", [])
            guild = AbstractGuild(g)
            c.state.guilds[guild.id] = guild
        end
    end

    c.hb_chan = Channel(ch -> maintain_heartbeat(c, ch))
    c.rl_chan = Channel(ch -> read_loop(c, ch))

    return nothing
end

Base.isopen(c::Client) = isdefined(c, :conn) && isopen(c.conn)

function Base.close(c::Client; statusnumber::Int=1000)
    isdefined(c, :conn) || return
    close(c.hb_chan)
    close(c.rl_chan)
    close(c.conn; statusnumber=statusnumber)
end

"""
    wait(c::Client)

Wait for an open client to close.
"""
Base.wait(c::Client) = isopen(c) && wait(c.conn.cond)

"""
    state(c::Client) -> Dict{String, Any}

Get the client state.
"""
state(c::Client) = c.state

"""
    me(c::Client) -> Dict{String, Any}

Get the client's bot user.
"""
me(c::Client) = get(c.state.state, "user", Dict{String, Any}())

# Event handlers.

"""
    add_handler!(c::Client, evt::Type{<:AbstractEvent}, func::Function)

Add a handler for the given event type.
The handler is appended the event's current handlers.
"""
function add_handler!(c::Client, evt::Type{<:AbstractEvent}, func::Function)
    if haskey(c.handlers, evt)
        push!(c.handlers[evt], func)
    else
        c.handlers[evt] = Function[func]
    end
end

"""
    clear_handlers!(c::Client, evt::Type{<:AbstractEvent})

Removes all handlers for the given event type.
"""
clear_handlers!(c::Client, event::Type{<:AbstractEvent}) = delete!(c.handlers, event)

# Client maintenance.

function maintain_heartbeat(c::Client, ch::Channel)
    while isopen(ch) && isopen(c.conn)
        if c.last_heartbeat > c.last_ack
            reconnect(c; statusnumber=1001)
        elseif !heartbeat(c) && isopen(ch)
            @error "writing HEARTBEAT failed"
        elseif isopen(ch)
            sleep(c.heartbeat_interval / 1000)
        end
    end
end

function read_loop(c::Client, ch::Channel)
    while isopen(ch) && isopen(c.conn)
        data, e = readjson(c.conn)
        if e !== nothing
            isopen(ch) || break
            handle_error(c, e)
        else
            haskey(HANDLERS, data["op"]) && HANDLERS[data["op"]](c, data)
        end
    end
end

# Event handlers

function dispatch(c::Client, data::Dict)
    c.heartbeat_seq = data["s"]
    evt = AbstractEvent(data)

    for handler in get(c.handlers, typeof(evt), Function[])
        @async try
            handler(evt)
        catch e
            @error sprint(showerror, e)
        end
    end
end

function heartbeat(c::Client, ::Dict=Dict())
    ok = writejson(c.conn, Dict("op" => 1, "d" => c.heartbeat_seq))

    if ok
        c.last_heartbeat = now()
    end

    return ok
end

function reconnect(c::Client, ::Dict=Dict(); resume::Bool=true, statusnumber::Int=1000)
    close(c; statusnumber=statusnumber)
    open(c; resume=resume)
end

function invalid_session(c::Client, data::Dict)
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

# Error handling
const CLOSE_CODES = Dict(
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

function handle_error(c::Client, e::Exception)
    if isa(e, WebSocketClosedError)
        handle_close(c, e)
    else
        @error sprint(showerror, e)
    end
end

function handle_close(c::Client, e::WebSocketClosedError)
    code = closecode(e)
    code === nothing && throw(e)
    err = get(CLOSE_CODES, code, :UNKNOWN_ERROR)

    if err === :UNKNOWN_ERROR
        reconnect(c)
    elseif err === :UNKNOWN_OPCODE
        reconnect(c)
    elseif err === :DECODE_ERROR  # Probably a library bug.
        reconnect(c)
    elseif err === :NOT_AUTHENTICATED  # Probably a library bug.
        reconnect(c)
    elseif err === :AUTHENTICATION_FAILED
        error("WebSocket connection was closed: $code $err")
    elseif err === :ALREADY_AUTHENTICATED  # Probably a library bug.
        reconnect(c)
    elseif err === :INVALID_SEQ  # Probably a library bug.
        reconnect(c)
    elseif err === :RATE_LIMITED  # Probably a library bug.
        @warn "WebSocket connection was closed: $code $err (reconnecting)"
        reconnect(c)
    elseif err === :SESSION_TIMEOUT
        reconnect(c)
    elseif err === :INVALID_SHARD
        error("WebSocket connection was closed: $code $err (sharding is not implemented)")
    elseif err === :SHARDING_REQUIRED
        error("WebSocket connection was closed: $code $err (sharding is not implemented)")
    end
end

# Helpers

function readjson(conn)
    return try
        json = read(conn)
        JSON.parse(String(json)), nothing
    catch e
        nothing, e
    end
end

writejson(conn, body) = writeguarded(conn, JSON.json(body))

function closecode(e::WebSocketClosedError)
    m = match(r"OPCODE_CLOSE (\d+)", e.message)

    return match === nothing ? nothing : parse(Int, String(first(m.captures)))
end
