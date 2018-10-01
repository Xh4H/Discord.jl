# Properties for gateway connections.
const conn_properties = Dict(
    "\$os" => String(Sys.KERNEL),
    "\$browser" => "Discord.jl",
    "\$device" => "Discord.jl",
)

struct Client
    token::String
    heartbeat_interval::Int
    heartbeat_seq::Union{Int, Nothing}
    conn::OpenTrick.IOWrapper
    state::Dict{String, Any}
    handlers::Dict

    function Client(token::String)
        if !startswith(token, "Bot ")
            throw(ArgumentError("bot token must be of format 'Bot <token>'"))
        end

        # Get the gateway URL and connect to it.
        resp = HTTP.get("$DISCORD_API/gateway")
        d = JSON.parse(String(resp.body))
        url = "$(d["url"])?v=6&encoding=json"
        conn = opentrick(WebSockets.open, url)

        # Receive HELLO, get heartbeat interval.
        data, ok = readjson(conn)
        if !ok
            @error "reading HELLO failed"
            return
        end
        heartbeat_interval = data["d"]["heartbeat_interval"]

        # Write the first heartbeat.
        if !writejson(conn, Dict("op" => 1, "d" => nothing))
            @error "writing HEARTBEAT failed"
            return
        end

        # Read the heartbeat ack.
        _, ok = readjson(conn)
        if !ok
            @error "reading HEARTBEAT_ACK failed"
            return
        end

        # Write the IDENTIFY.
        if !writejson(conn, Dict(
            "op" => 2,
            "d" => Dict(
                "token" => token,
                "properties" => conn_properties,
            ),
        ))
            @error "writing IDENTIFY failed"
            return
        end

        # Read the READY message, and assign initial state.
        data, ok = readjson(conn)
        if !ok
            @error "reading READY failed"
            return
        end
        state = data["d"]

        c = new(token, heartbeat_interval, nothing, conn, state, Dict())

        @async maintain_heartbeat(c)
        @async event_loop(c)

        return c
    end
end

Base.isopen(c::Client) = isopen(c.conn)
Base.close(c::Client) = close(c.conn)

state(c::Client) = c.state

# Event handlers.

function add_handler!(c::Client, event::Type{<:AbstractEvent}, handler::Function)
    if haskey(c.handlers, event)
        push!(c.handlers[event], handler)
    else
        c.handlers[event] = [handler]
    end
end

clear_handlers!(c::Client, event::Type{<:AbstractEvent}) = delete!(c.handlers, event)

# Heartbeat maintenance.

send_heartbeat(c::Client) = writejson(c.conn, Dict("op" => 2, "d" => c.heartbeat_seq))

function maintain_heartbeat(c::Client)
    while isopen(c.conn)
        if !send_heartbeat(c)
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
            @error "read from websocket failed"
            continue
        end
        haskey(HANDLERS, data["op"]) && HANDLERS[data["op"]](c, data)
    end
end

# Event handlers (TODO)

function dispatch(c::Client, data::Dict)
    c.heartbeat_seq = data["s"]
    evt = convert(AbstractEvent, data)
    for handler in get(c.handlers, typeof(t), [])
        handler(evt)
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
