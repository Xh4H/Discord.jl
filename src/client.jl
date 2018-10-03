export Client,
    state,
    me,
    add_handler!,
    clear_handlers!

# Properties for gateway connections.
const conn_properties = Dict(
    "\$os" => String(Sys.KERNEL),
    "\$browser" => "Julicord",
    "\$device" => "Julicord",
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
    state::Dict{String, Any}  # TODO: This should be a struct.
    handlers::Dict{Type{<:AbstractEvent}, Vector{Function}}
    closed::Bool
    conn::OpenTrick.IOWrapper

    function Client(token::String)
        token = startswith(token, "Bot ") ? token : "Bot $token"
        return new(token, 0, nothing, Dict(), Dict(), true)
    end
end


"""
    open(c::Client)

Logs in to the Discord gateway and begins reading events.
"""
function Base.open(c::Client)
    # Get the gateway URL and connect to it.
    resp = HTTP.get("$DISCORD_API/gateway")
    d = JSON.parse(String(resp.body))
    url = "$(d["url"])?v=$API_VERSION&encoding=json"
    conn = opentrick(WebSockets.open, url)
    c.conn = conn
    c.closed = false

    # Receive HELLO, get heartbeat interval.
    data, ok = readjson(conn)
    ok || error("reading HELLO failed")
    c.heartbeat_interval = data["d"]["heartbeat_interval"]

    # Write the first heartbeat.
    send_heartbeat(c) || error("writing HEARTBEAT failed")

    # Read the heartbeat ack.
    _, ok = readjson(conn)
    ok || error("reading HEARTBEAT_ACK failed")

    # Write the IDENTIFY.
    writejson(conn, Dict(
        "op" => 2,
        "d" => Dict(
            "token" => c.token,
            "properties" => conn_properties,
        ),
    )) || error("writing IDENTIFY failed")

    # Read the READY message, and assign initial state.
    data, ok = readjson(conn)
    ok || error("reading READY failed")
    c.state = data["d"]

    @async maintain_heartbeat(c)
    @async event_loop(c)

    return nothing
end

Base.isopen(c::Client) = isdefined(c, :conn) && isopen(c.conn)

function Base.close(c::Client)
    isdefined(c, :conn) || return
    c.closed = true
    close(c.conn)
end

"""
    state(c::Client) -> Dict{String, Any}

Get the client state.
"""
state(c::Client) = c.state

"""
    me(c::Client) -> Dict{String, Any}

Get the client's bot user.
"""
me(c::Client) = get(c.state, "user", Dict{String, Any}())

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

# Heartbeat maintenance.

send_heartbeat(c::Client) = writejson(c.conn, Dict("op" => 1, "d" => c.heartbeat_seq))

function maintain_heartbeat(c::Client)
    while isopen(c.conn)
        if !send_heartbeat(c)
            c.closed && return
            @error "writing HEARTBEAT failed"
        else
            sleep(c.heartbeat_interval / 1000)
        end
    end
end

# Event loop.

function event_loop(c::Client)
    while isopen(c.conn)
        data, ok = readjson(c.conn)
        if !ok
            c.closed && return
            @error "read from websocket failed"
            continue
        end
        haskey(HANDLERS, data["op"]) && HANDLERS[data["op"]](c, data)
    end
end

# Event handlers (TODO)

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

heartbeat(c::Client, ::Dict) = send_heartbeat(c)

reconnect(::Client, ::Dict) = nothing
invalid_session(::Client, ::Dict) = nothing
hello(::Client, ::Dict) = nothing
heartbeat_ack(::Client, ::Dict) = nothing

# Gateway opcodes => handler function.
const HANDLERS = Dict(
    0 => dispatch,
    1 => heartbeat,
    7 => reconnect,
    9 => invalid_session,
    10 => hello,
    11 => heartbeat_ack,
)

# Helpers

function readjson(conn)
    json, ok = readguarded(conn)
    ok ? JSON.parse(String(json)) : nothing, ok
end

writejson(conn, body) = writeguarded(conn, JSON.json(body))
