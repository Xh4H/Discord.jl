export Client,
    me,
    set_ttl!,
    enable_cache!,
    disable_cache!,
    add_handler!,
    delete_handler!

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
    use_cache::Bool             # Whether or not to use the cache for REST ops.
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
            true,         # use_cache
            # conn left undef, it gets assigned in open.
        )
        add_handler!(c, Defaults)
        return c
    end
end

"""
    me(c::Client) -> Union{User, Nothing}

Get the [`Client`](@ref)'s bot user.
"""
me(c::Client) = c.state.user

"""
    set_ttl!(c::Client, ttl::Period)

Set the [`Client`](@ref)'s caching period.
"""
set_ttl!(c::Client, ttl::Period) = c.ttl = c.state.ttl = ttl

"""
    enable_cache!(c::Client)
    enable_cache!(f::Function c::Client)

Enable the cache for REST operations.
"""
enable_cache!(c::Client) = c.use_cache = true
enable_cache!(f::Function, c::Client) = setcache(f, c, true)

"""
    disable_cache!(c::Client)
    disable_cache!(f::Function, c::Client)

Disable the cache for REST operations.
"""
disable_cache!(c::Client) = c.use_cache = false
disable_cache!(f::Function, c::Client) = setcache(f, c, false)

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
the event's current handlers. You can also define a single handler for multuple event types
by using a `Union`.

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
    if evt isa Union
        add_handler!(c, evt.a, func; tag=tag, expiry=expiry)
        add_handler!(c, evt.b, func; tag=tag, expiry=expiry)
        return
    end

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

function Base.tryparse(c::Client, T::Type, data)
    return try
        T <: Vector ? eltype(T).(data) : T(data), nothing
    catch e
        logmsg(c, ERROR, catchmsg(e))
        push!(c.state.errors, data)
        nothing, e
    end
end

function setcache(f::Function, c::Client, use_cache::Bool)
    old = c.use_cache
    c.use_cache = use_cache
    try
        f()
    finally
        # Usually the above function is going to be calling REST endpoints. The cache flag
        # is checked asynchronously, so by the time it happens there's a good chance we've
        # already returned and set the cache flag back to its original value.
        sleep(Milliscond(1))
        c.use_cache = old
    end
end
