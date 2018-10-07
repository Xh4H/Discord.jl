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
    last_heartbeat::DateTime
    last_ack::DateTime
    state::Dict{String, Any}  # TODO: This should be a struct.
    handlers::Dict{Type{<:AbstractEvent}, Vector{Function}}
    hb_chan::Channel
    el_chan::Channel
    conn::OpenTrick.IOWrapper

    function Client(token::String)
        token = startswith(token, "Bot ") ? token : "Bot $token"
        return new(
            token,
            0,
            nothing,
            unix2datetime(0),
            Dict(),
            Dict(),
            Channel(0),
            Channel(0),
        )
    end
end


"""
    open(c::Client)

Log in to the Discord gateway and begin reading events.
"""
function Base.open(c::Client)
    isopen(c) && @error "Client is already open"

    # Get the gateway URL and connect to it.
    resp = HTTP.get("$DISCORD_API/gateway")
    d = JSON.parse(String(resp.body))
    url = "$(d["url"])?v=$API_VERSION&encoding=json"
    conn = opentrick(WebSockets.open, url)
    c.conn = conn

    # Receive HELLO, get heartbeat interval.
    data, ok = readjson(conn)
    ok || error("reading HELLO failed")
    hello(c, data)

    # Write the first heartbeat.
    send_heartbeat(c) || error("writing HEARTBEAT failed")

    # Read the heartbeat ack.
    data, ok = readjson(conn)
    ok || error("reading HEARTBEAT_ACK failed")
    heartbeat_ack(c, data)

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

    c.hb_chan = Channel(ch -> maintain_heartbeat(c, ch))
    c.el_chan = Channel(ch -> event_loop(c, ch))

    return nothing
end

Base.isopen(c::Client) = isdefined(c, :conn) && isopen(c.conn)

function Base.close(c::Client)
    isdefined(c, :conn) || return
    close(c.hb_chan)
    close(c.el_chan)
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

function send_heartbeat(c::Client)
    ok = writejson(c.conn, Dict("op" => 1, "d" => c.heartbeat_seq))
    if ok
        c.last_heartbeat = now()
    end
    return ok
end

function maintain_heartbeat(c::Client, ch::Channel)
    while isopen(c.conn)
        if !send_heartbeat(c)
            isopen(ch) || return
            @error "writing HEARTBEAT failed"
        else
            sleep(c.heartbeat_interval / 1000)
        end
    end
end

# Event loop.

function event_loop(c::Client, ch::Channel)
    while isopen(c.conn)
        data, ok = readjson(c.conn)
        if !ok
            isopen(ch) || return
            @error "read from websocket failed"
        else
            haskey(HANDLERS, data["op"]) && HANDLERS[data["op"]](c, data)
        end
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
hello(c::Client, data::Dict) = c.heartbeat_interval = data["d"]["heartbeat_interval"]
heartbeat_ack(c::Client, ::Dict) = c.last_ack = now()

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
