export Client,
    me,
    enable_cache!,
    disable_cache!,
    add_handler!,
    delete_handler!,
    DEFAULT_HANDLER_TAG

include("limiter.jl")
include("state.jl")
include("handlers.jl")

"""
Tag assigned to default handlers, which you can use to delete them.
"""
const DEFAULT_HANDLER_TAG = :DJL_DEFAULT

# Messages are created regularly, and lose relevance quickly.
const DEFAULT_STRATEGIES = Dict{DataType, CacheStrategy}(
    Guild          => CacheForever(),
    DiscordChannel => CacheForever(),
    User           => CacheForever(),
    Member         => CacheForever(),
    Presence       => CacheForever(),
    Message        => CacheTTL(Hour(6)),
)

# A versioned WebSocket connection.
mutable struct Conn
    io
    v::Int
end

"""
    Client(
        token::String;
        prefix::String="",
        presence::Union{Dict, NamedTuple}=Dict(),
        strategies::Dict{DataType, <:CacheStrategy}=Dict(),
        version::Int=$API_VERSION,
    ) -> Client

A Discord bot. `Client`s can connect to the gateway, respond to events, and make REST API
calls to perform actions such as sending/deleting messages, kicking/banning users, etc.

### Bot Token
A bot token can be acquired by creating a new application
[here](https://discordapp.com/developers/applications). Make sure not to hardcode the token
into your Julia code! Use an environment variable or configuration file instead.

### Command Prefix
The `prefix` keyword specifies the command prefix, which is used by commands added with
[`add_command!`](@ref). It can be changed later, both globally and on a per-guild basis,
with [`set_prefix!`](@ref).

### Presence
The `presence` keyword sets the bot's presence upon connection. It also sets defaults
for future calls to [`set_game`](@ref). The schema
[here](https://discordapp.com/developers/docs/topics/gateway#update-status-gateway-status-update-structure)
must be followed.

### Cache Control
By default, most data that comes from Discord is cached for later use. However, to avoid
memory leakage, not all of it is kept forever. The default setings are to keep everything
but [`Message`](@ref)s, which are deleted after 6 hours, forever. Although the default
settings are sufficient for most workloads, you can specify your own strategies per type
with the `strategies` keyword. Keys can be any of the following:

- [`Guild`](@ref)
- [`DiscordChannel`](@ref)
- [`Message`](@ref)
- [`User`](@ref)
- [`Member`](@ref)
- [`Presence`](@ref)

For potential values, see [`CacheStrategy`](@ref).

The cache can also be disabled/enabled permanently and temporarily as a whole with
[`enable_cache!`](@ref) and [`disable_cache!`](@ref).

### API Version
The `version` keyword chooses the Version of the Discord API to use. Using anything but
`$API_VERSION` is not officially supported by the Discord.jl developers.

### Sharding
Sharding is handled automatically. The number of available processes is the number of
shards that are created. See the
[sharding example](https://github.com/PurgePJ/Discord.jl/blob/master/examples/sharding.jl)
for more details.
"""
mutable struct Client
    token::String          # Bot token, always with a leading "Bot ".
    hb_interval::Int       # Milliseconds between heartbeats.
    hb_seq::Nullable{Int}  # Sequence value sent by Discord for resuming.
    last_hb::DateTime      # Last heartbeat send.
    last_ack::DateTime     # Last heartbeat ack.
    version::Int           # Discord API version.
    state::State           # Client state, cached data, etc.
    shards::Int            # Number of shards in use.
    shard::Int             # Client's shard index.
    limiter::Limiter       # Rate limiter.
    ready::Bool            # Client is connected and authenticated.
    use_cache::Bool        # Whether or not to use the cache.
    presence::Dict         # Default presence options.
    conn::Conn             # WebSocket connection.
    p_global::String       # Default command prefix.
    p_guilds::Dict{Snowflake, String}  # Command prefix overrides.
    handlers::Dict{Type{<:AbstractEvent}, Dict{Symbol, AbstractHandler}}  # Event handlers.

    function Client(
        token::String;
        prefix::StringOrChar="",
        presence::Union{Dict, NamedTuple}=Dict(),
        strategies::Dict{DataType, <:CacheStrategy}=Dict{DataType, CacheStrategy}(),
        version::Int=API_VERSION,
    )
        token = startswith(token, "Bot ") ? token : "Bot $token"
        state = State(merge(DEFAULT_STRATEGIES, strategies))
        conn = Conn(nothing, 0)
        prefix = string(prefix)
        presence = merge(Dict(
            "since" => nothing,
            "game" => nothing,
            "status" => PS_ONLINE,
            "afk" => false,
        ), Dict(string(k) => v for (k, v) in Dict(pairs(presence))))

        c = new(
            token,        # token
            0,            # hb_interval
            nothing,      # hb_seq
            DateTime(0),  # last_hb
            DateTime(0),  # last_ack
            version,      # version
            state,        # state
            nprocs(),     # shards
            myid() - 1,   # shard
            Limiter(),    # limiter
            false,        # ready
            true,         # use_cache
            presence,     # presence
            conn,         # conn
            prefix,       # p_global
            Dict(),       # p_guilds
            Dict(),       # handlers
        )

        add_handler!(c, Defaults; tag=DEFAULT_HANDLER_TAG, priority=typemax(Int) - 10)
        return c
    end
end

mock(::Type{Client}; kwargs...) = Client("token")

function Base.show(io::IO, c::Client)
    print(io, "Discord.Client(shard=$(c.shard + 1)/$(c.shards), api=$(c.version), ")
    isempty(c.p_global) || print(io, """prefix="$(c.p_global)", """)
    isopen(c) || print(io, "not ")
    print(io, "logged in)")
end

"""
    me(c::Client) -> Nullable{User}

Get the [`Client`](@ref)'s bot user.
"""
me(c::Client) = c.state.user

"""
    enable_cache!(c::Client)
    enable_cache!(f::Function c::Client)

Enable the cache. `do` syntax is also accepted.
"""
enable_cache!(c::Client) = c.use_cache = true
enable_cache!(f::Function, c::Client) = set_cache(f, c, true)

"""
    disable_cache!(c::Client)
    disable_cache!(f::Function, c::Client)

Disable the cache. `do` syntax is also accepted.
"""
disable_cache!(c::Client) = c.use_cache = false
disable_cache!(f::Function, c::Client) = set_cache(f, c, false)

"""
    add_handler!(
        c::Client,
        [T::Type{<:AbstractEvent}],
        handler::Function;
        tag::Symbol=gensym(),
        predicate::Function=alwaystrue,
        fallback::Function=donothing,
        priority::Int=$DEFAULT_PRIORITY,
        count::Nullable{Int}=nothing,
        timeout::Nullable{Period}=nothing,
        until::Function=alwaysfalse,
        wait::Bool=false,
        compile::Bool=false,
        kwargs...,
    ) -> Nullable{Vector{Any}}

Add an event handler. `do` syntax is also accepted.

### Handler Function
The handler function does the real work and must take two arguments: A [`Client`](@ref) and
an [`AbstractEvent`](@ref) (or a subtype). If an event type `T` is supplied, then the
handler is registered for that event. Otherwise, the second argument of the handler
must be annotated, and the type annotation determines what events will invoke the
handler. `Union` types are also accepted to register handlers for multiple events.

### Handler Tag
The `tag` keyword gives a label to the handler, which can be used to remove it with
[`delete_handler!`](@ref).

### Predicate/Fallback Functions
The `predicate` keyword specifies a predicate function. The handler will only run if this
function returns `true`. Otherwise, a fallback function, specified by the `fallback`
keyword, is run. Their signatures should match that of the handler.

### Handler Priority
The `priority` keyword indicates the handler's priority relative to other handlers for the
same event. Handlers with higher values execute before those with lower ones.

### Handler Expiry
Handlers can have multiple types of expiries. The `count` keyword sets the number of times
a handler is run before expiring. The `timeout` keyword determines how long the handler
remains active. The `until` keyword takes a function which is called on the handler's
previous results (in a `Vector`), and if it returns `true`, the handler expires. These
keywords can be combined; the first condition to be met causes the handler to expire.

### Blocking Handlers + Result Collection
To collect results from a handler, set the `wait` keyword along with `n`, `timeout`, and/or
`until`. The call will block until the handler expires, at which point the return value of
each invocation is returned in a `Vector`.

### Forcing Precompilation
Handler functions are precompiled without running them, but it's not always
successful, especially if your functions are not type-safe. If the `compile` keyword is
set, precompilation is forced by running the predicate and handler on a randomized input.
Any trailing keywords are passed to the constructors of the event and its fields.

## Examples
Basic "hello world" with explicit event type:
```julia
add_handler!(c, MessageCreate, (c, e) -> println(e.message.content); tag=:print)
```
Adding a handler with a predicate and fallback:
```julia
handler(::Client, e::ChannelCreate) = println(e.channel.name)
predicate(::Client, e::ChannelCreate) = length(e.channel.name) < 10
fallback(::Client, ::ChannelCreate) = println("channel name too long")
add_handler!(c, handler; predicate=predicate, fallback=fallback)
```
Assigning maximum priority to a handler:
```julia
handler(:::Client, ::MessageCreate) = println("this runs before any other handlers!")
add_handler!(c, handler; priority=typemax(Int))
```
Adding a handler with various expiry conditions:
```julia
handler(::Client, e::ChannelCreate) = e.channel.name
until(results::Vector{Any}) = "foo" in results
add_handler!(c, handler; count=10, timeout=Minute(1), until=until)
```
Aggregating results of a handler:
```julia
handler(::Client, e::MessageCreate) = e.message.content
msgs = add_handler!(c, handler; count=5, wait=true)
```
Forcing precompilation:
```julia
handler(::Client, e::MessageDelete) = @show e
add_handler!(c, handler; compile=true, id=0xff)
```
"""
function add_handler!(
    c::Client,
    handler::Function;
    tag::Symbol=gensym(),
    predicate::Function=alwaystrue,
    fallback::Function=donothing,
    priority::Int=DEFAULT_PRIORITY,
    count::Nullable{Int}=nothing,
    timeout::Nullable{Period}=nothing,
    until::Function=alwaysfalse,
    wait::Bool=false,
    compile::Bool=false,
    kwargs...,
)
    sigs = map(m -> m.sig.types[2:end], methods(handler).ms)
    Ts = vcat(map(T -> T isa Union ? [T.a, T.b] : [T], map(last, sigs))...)

    if isempty(Ts)
        throw(ArgumentError("Must specify at least one event type"))
    elseif length(Ts) > 1 && wait
        throw(ArgumentError("Can only wait for one event type at a time"))
    elseif any(s -> length(s) !== 2, sigs)
        throw(ArgumentError("Handlers must only accept 2 arguments"))
    elseif any(s -> s[1] !== Client, sigs)
        throw(ArgumentError("First argument to handler must be a Client"))
    elseif !all(s -> s[2] <: AbstractEvent, sigs)
        throw(ArgumentError("Second argument to handler must be <: AbstractEvent"))
    end

    wait && return add_handler!(
        c, Ts[1], handler;
        tag=tag, predicate=predicate, fallback=fallback, priority=priority,
        count=count, timeout=timeout, until=until, wait=wait,
        compile=compile, kwargs...,
    )

    for T in Ts
        add_handler!(
            c, T, handler;
            tag=tag, predicate=predicate, fallback=fallback, priority=priority,
            count=count, timeout=timeout, until=until, wait=wait,
            compile=compile, kwargs...,
        )
    end
end

function add_handler!(
    c::Client,
    T::Type{<:AbstractEvent},
    handler::Function;
    tag::Symbol=gensym(),
    predicate::Function=alwaystrue,
    fallback::Function=donothing,
    priority::Int=DEFAULT_PRIORITY,
    count::Nullable{Int}=nothing,
    timeout::Nullable{Period}=nothing,
    until::Function=alwaysfalse,
    wait::Bool=false,
    compile::Bool=false,
    kwargs...,
)
    if wait && !isopen(c)
        throw(ArgumentError("Can't wait for a handler with a disconnected Client"))
    elseif wait && T isa Union
        throw(ArgumentError("Can only wait for one event at a time"))
    elseif wait && all(isequal(nothing), [count, timeout, until])
        throw(ArgumentError("Can't wait for a handler with no expiry"))
    end

    if T isa Union
        add_handler!(
            c, T.a, handler;
            tag=tag, predicate=predicate, fallback=fallback, priority=priority,
            count=count, timeout=timeout, compile=compile, kwargs...,
        )
        add_handler!(
            c, T.b, handler;
            tag=tag, predicate=predicate, fallback=fallback, priority=priority,
            count=count, timeout=timeout, compile=compile, kwargs...,
        )
        return
    end

    col = wait || until !== alwaysfalse
    h = Handler{T}(predicate, handler, fallback, priority, count, timeout, until, col)
    puthandler!(c, h, tag, compile; kwargs...)

    return wait ? take!(h) : nothing
end

add_handler!(handler::Function, c::Client; kwargs...) = add_handler!(c, handler; kwargs...)
function add_handler!(handler::Function, c::Client, T::Type{<:AbstractEvent}; kwargs...)
    return add_handler!(c, T, handler; kwargs...)
end

"""
    add_handler!(c::Client, m::Module; kwargs...)

Add all of the event handlers defined in a module. Any function you wish to use as a
handler must be exported. Only functions with correct, annotated type signatures (see
above) are used.

!!! note
    If you set keywords, they are applied to all of the handlers in the module. For
    example, if you add two handlers for the same event type with the same tag, one of them
    will be immediately overwritten.
"""
function add_handler!(c::Client, m::Module; kwargs...)
    for f in filter(f -> f isa Function, map(n -> getfield(m, n), names(m)))
        for m in methods(f)
            length(m.sig.types) == 3 || continue
            if m.sig.types[2] === Client && m.sig.types[3] <: AbstractEvent
                add_handler!(c, m.sig.types[3], f; kwargs...)
            end
        end
    end
end

"""
    delete_handler!(c::Client, T::Type{<:AbstractEvent}, tag::Symbol)
    delete_handler!(c::Client, T::Type{<:AbstractEvent})

Delete event handlers. If no `tag` is supplied, all handlers for the event are deleted.
Using the tagless method is generally not recommended because it also clears default
handlers which maintain the client state. If you do want to delete a default handler, use
[`DEFAULT_HANDLER_TAG`](@ref).
"""
function delete_handler!(c::Client, T::Type{<:AbstractEvent}, tag::Symbol)
    hs = get(c.handlers, T, Dict())
    h = get(hs, tag, nothing)
    if h !== nothing
        put!(h, results(h))
        delete!(hs, tag)
    end
end
function delete_handler!(c::Client, T::Type{<:AbstractEvent})
    foreach(p -> delete_handler!(c, T, p.first), get(c.handlers, T, Dict()))
    delete!(c.handlers, T)
end

# Get all handlers for a specific event.
function handlers(c::Client, T::Type{<:AbstractEvent})
    return collect(filter(p -> !isexpired(p.second), get(c.handlers, T, Dict())))
end

# Get all handlers that should be run for an event, including catch-alls and fallbacks.
function allhandlers(c::Client, T::Type{<:AbstractEvent})
    catchalls = T === AbstractEvent ? Handler[] : handlers(c, AbstractEvent)
    specifics = handlers(c, T)
    fallbacks = T === FallbackEvent ? Handler[] : handlers(c, FallbackEvent)

    return if isempty(catchalls) && isempty(specifics)
        fallbacks
    elseif isempty(catchalls) && all(h -> h.first === DEFAULT_HANDLER_TAG, specifics)
        [specifics; fallbacks]
    else
        [catchalls; specifics]
    end
end

# Determine whether a default handler exists for an event.
function hasdefault(c::Client, T::Type{<:AbstractEvent})
    return haskey(get(c.handlers, T, Dict()), DEFAULT_HANDLER_TAG)
end

# Compute some contextual keywords for log messages.
function logkws(c::Client; kwargs...)
    kws = Pair[:time => now()]
    c.shards > 1 && push!(kws, :shard => c.shard)
    c.conn.io === nothing || push!(kws, :conn => c.conn.v)

    for kw in kwargs
        if kw.second === undef  # Delete any keys overridden with undef.
            filter!(p -> p.first !== kw.first, kws)
        else
            # Replace any overridden keys.
            idx = findfirst(p -> p.first === kw.first, kws)
            if idx === nothing
                push!(kws, kw)
            else
                kws[idx] = kw
            end
        end
    end

    return kws
end

# Parse some data (usually a Dict from JSON), or return the thrown error.
function Base.tryparse(c::Client, T::Type, data)
    return try
        T <: Vector ? eltype(T).(data) : T(data), nothing
    catch e
        kws = logkws(c; T=T, exception=(e, catch_backtrace()))
        @error "Parsing failed" kws...
        nothing, e
    end
end

# Run some function with the cache enabled or disabled.
function set_cache(f::Function, c::Client, use_cache::Bool)
    old = c.use_cache
    c.use_cache = use_cache
    try
        f()
    finally
        # Usually the above function is going to be calling REST endpoints. The cache flag
        # is checked asynchronously, so by the time it happens there's a good chance we've
        # already returned and set the cache flag back to its original value.
        sleep(Millisecond(1))
        c.use_cache = old
    end
end

# Add a handler to the client.
function puthandler!(c::Client, h::AbstractHandler, tag::Symbol, force::Bool; kwargs...)
    T = eltype(h)

    if !hasmethod(handler(h), (Client, T))
        throw(ArgumentError("Handler function must accept (::Client, ::$T)"))
    end
    if !hasmethod(predicate(h), (Client, T))
        throw(ArgumentError("Predicate function must accept (::Client, ::$T)"))
    end
    if any(r -> !hasmethod(fallback(h, r), (Client, T)), instances(FallbackReason))
        throw(ArgumentError("Fallback functions must accept (::Client, ::$T)"))
    end
    if isexpired(h)
        throw(ArgumentError("Can't add a handler that's already expired"))
    end

    compile(predicate(h), force; kwargs...)
    compile(handler(h), force; kwargs...)
    foreach(r -> compile(fallback(h, r), force; kwargs...), instances(FallbackReason))

    if haskey(c.handlers, T)
        c.handlers[T][tag] = h
    else
        c.handlers[T] = Dict(tag => h)
    end
end
