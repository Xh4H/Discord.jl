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
const DEFAULT_TTLS = TTLDict(
    Guild          => nothing,
    DiscordChannel => nothing,
    User           => nothing,
    Member         => nothing,
    Presence       => nothing,
    Message        => Hour(6),
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
        ttls::$TTLDict=Dict(),
        version::Int=$API_VERSION,
    ) -> Client

A Discord bot. `Client`s can connect to the gateway, respond to events, and make REST API
calls to perform actions such as sending/deleting messages, kicking/banning users, etc.

# Keywords
- `prefix::String=""`: Command prefix (see [`set_prefix!`](@ref) and
  [`add_command!`](@ref)).
- `presence::Union{Dict, NamedTuple}=Dict()`: Client's presence set upon connection.
  The schema [here](https://discordapp.com/developers/docs/topics/gateway#update-status-gateway-status-update-structure)
  must be followed.
- `ttls::$TTLDict=Dict()`: Cache lifetime overrides. Values of `nothing` indicate no
  expiry. Keys can be any of the following: [`Guild`](@ref), [`DiscordChannel`](@ref),
  [`Message`](@ref), [`User`](@ref), [`Member`](@ref), or [`Presence`](@ref). For most
  workloads, the defaults are sufficient.
- `version::Int=$API_VERSION`: Version of the Discord API to use. Using anything but
  $API_VERSION is not officially supported by the Discord.jl developers.
"""
mutable struct Client
    token::String                # Bot token, always with a leading "Bot ".
    hb_interval::Int             # Milliseconds between heartbeats.
    hb_seq::Union{Int, Nothing}  # Sequence value sent by Discord for resuming.
    last_hb::DateTime            # Last heartbeat send.
    last_ack::DateTime           # Last heartbeat ack.
    ttls::TTLDict                # Cache lifetimes.
    version::Int                 # Discord API version.
    state::State                 # Client state, cached data, etc.
    shards::Int                  # Number of shards in use.
    shard::Int                   # Client's shard index.
    limiter::Limiter             # Rate limiter.
    ready::Bool                  # Client is connected and authenticated.
    use_cache::Bool              # Whether or not to use the cache.
    presence::Dict               # Default presence options.
    conn::Conn                   # WebSocket connection.
    p_global::AbstractString     # Default command prefix.
    p_guilds::Dict{Snowflake, AbstractString}  # Command prefix overrides.
    handlers::Dict{Type{<:AbstractEvent}, Dict{Symbol, AbstractHandler}}  # Event handlers.

    function Client(
        token::String;
        prefix::String="",
        presence::Union{Dict, NamedTuple}=Dict(),
        ttls::TTLDict=TTLDict(),
        version::Int=API_VERSION,
    )
        token = startswith(token, "Bot ") ? token : "Bot $token"
        ttls = merge(DEFAULT_TTLS, ttls)
        state = State(ttls)
        conn = Conn(nothing, 0)
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
            ttls,         # ttls
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

        add_handler!(c, Defaults; tag=DEFAULT_HANDLER_TAG)
        return c
    end
end

mock(::Type{Client}; kwargs...) = Client("token")

function Base.show(io::IO, c::Client)
    print(io, "Discord.Client(shard=$(c.shard + 1)/$(c.shards), api=$(c.version), ")
    isopen(c) || print(io, "not ")
    print(io, "logged in)")
end

"""
    me(c::Client) -> Union{User, Nothing}

Get the [`Client`](@ref)'s bot user.
"""
me(c::Client) = c.state.user

"""
    enable_cache!(c::Client)
    enable_cache!(f::Function c::Client)

Enable the cache. `do` syntax is also supported.
"""
enable_cache!(c::Client) = c.use_cache = true
enable_cache!(f::Function, c::Client) = set_cache(f, c, true)

"""
    disable_cache!(c::Client)
    disable_cache!(f::Function, c::Client)

Disable the cache. `do` syntax is also supported.
"""
disable_cache!(c::Client) = c.use_cache = false
disable_cache!(f::Function, c::Client) = set_cache(f, c, false)

"""
    add_handler!(
        c::Client,
        T::Type{<:AbstractEvent},
        func::Function;
        tag::Symbol=gensym(),
        n::Union{Int, Nothing}=nothing,
        timeout::Union{Period, Nothing}=nothing,
        wait::Bool=false,
        compile::Bool=false,
        kwargs...,
    ) -> Union{Vector{Any}, Nothing}

Add an event handler. `do` syntax is also accepted.

# Handler Function
The handler function must take two arguments: A [`Client`](@ref) and an
[`AbstractEvent`](@ref) (or a subtype).

# Handler Tag
The `tag` keyword specifies a label for the handler, which can be used to remove it with
[`delete_handler!`](@ref).

# Predicate Function
The `pred` keyword specifies a predicate function. The handler will only run if this
function returns `true`. Its signature should match that of the handler.

# Handler Expiry
Handlers can have counting and/or timed expiries. The `n` keyword specifies the number of
times a handler is run before expiring. The `timeout` keyword specifies how long the
handler remains active.

# Blocking Handlers and Result Collection
To collect results from a handler, set the `wait` keyword along with an expiry. The call
will block until the handler expires, at which point the return value of each invocation is
returned in a `Vector`.

# Forcing Precompilation
Predicates and handlers are precompiled without running them, but it's not always
successful. If the `compile` keyword is set, precompilation is forced by running
the predicate and handler on a randomized input. Any trailing keywords are passed to the
input event constructor.

# Examples
Adding a handler with a timed expiry and tag:
```julia
julia> add_handler!(c, ChannelCreate, (c, e) -> @show e; tag=:show, timeout=Minute(1))
```
Adding a handler with a predicate and `do` syntax:
```julia
julia> add_handler!(c, ChannelCreate; pred=(c, e) -> length(e.channel.name) < 10) do c, e
           println(e.channel.name)
       end
```
Aggregating results of a handler with a counting expiry:
```julia
julia> msgs = add_handler!(c, MessageCreate, (c, e) -> e.message.content; n=5, wait=true)
```
Forcing precompilation:
```julia
julia> add_handler!(c, MessageCreate, (c, e) -> @show e; compile=true)
```

!!! note
    There is no guarantee on the order in which handlers run, except that catch-all
    ([`AbstractEvent`](@ref)) handlers run before specific ones.
"""
function add_handler!(
    c::Client,
    T::Type{<:AbstractEvent},
    func::Function;
    tag::Symbol=gensym(),
    pred::Function=alwaystrue,
    n::Union{Int, Nothing}=nothing,
    timeout::Union{Period, Nothing}=nothing,
    wait::Bool=false,
    compile::Bool=false,
    kwargs...,
)
    if T isa Union
        wait && throw(ArgumentError("Can only wait for one event at a time"))
        add_handler!(
            c, T.a, func;
            tag=tag, pred=pred, n=n, timeout=timeout, compile=compile, kwargs...,
        )
        add_handler!(
            c, T.b, func;
            tag=tag, pred=pred, n=n, timeout=timeout, compile=compile, kwargs...,
        )
        return
    end

    h = Handler{T}(func, pred, n, timeout, wait)
    puthandler!(c, h, tag, compile; kwargs...)

    return wait ? take!(h) : nothing
end

function add_handler!(
    func::Function,
    c::Client,
    T::Type{<:AbstractEvent};
    tag::Symbol=gensym(),
    pred::Function=alwaystrue,
    n::Union{Int, Nothing}=nothing,
    timeout::Union{Period, Nothing}=nothing,
    wait::Bool=false,
    compile::Bool=false,
)
    return add_handler!(
        c, T, func;
        tag=tag, pred=pred, n=n, timeout=timeout, wait=wait, compile=compile,
    )
end

"""
    add_handler!(
        c::Client,
        m::Module;
        tag::Symbol=gensym(),
        pred::Function=alwaystrue,
        n::Union{Int, Nothing}=nothing,
        timeout::Union{Period, Nothing}=nothing,
        compile::Bool=false,
    )

Add all of the event handlers defined in a module. Any function you wish to use as a
handler must be exported. Only functions with correct type signatures (see above) are used.

!!! note
    If you specify keywords, they are applied to all of the handlers in the module. For
    example, if you add two handlers for the same event type with the same tag, one of them
    will be immediately overwritten.
"""
function add_handler!(
    c::Client,
    m::Module;
    tag::Symbol=gensym(),
    pred::Function=alwaystrue,
    n::Union{Int, Nothing}=nothing,
    timeout::Union{Period, Nothing}=nothing,
    compile::Bool=false,
)
    for f in filter(f -> f isa Function, map(n -> getfield(m, n), names(m)))
        for m in methods(f)
            ts = m.sig.types[2:end]
            length(m.sig.types) == 3 || continue
            if m.sig.types[2] === Client && m.sig.types[3] <: AbstractEvent
                add_handler!(
                    c, m.sig.types[3], f;
                    tag=tag, pred=pred, n=n, timeout=timeout, compile=compile,
                )
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

function Base.tryparse(c::Client, T::Type, data)
    return try
        T <: Vector ? eltype(T).(data) : T(data), nothing
    catch e
        @error catchmsg(e) logkws(c; T=T)...
        push!(c.state.errors, data)
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

    if !hasmethod(func(h), (Client, T))
        throw(ArgumentError("Handler function must accept (::Client, ::$T)"))
    end
    if !hasmethod(pred(h), (Client, T))
        throw(ArgumentError("Predicate function must accept (::Client, ::$T)"))
    end
    if isexpired(h)
        throw(ArgumentError("Can't add a handler that's already expired"))
    end

    compile(pred(h), force; kwargs...)
    compile(func(h), force; kwargs...)

    if haskey(c.handlers, T)
        c.handlers[T][tag] = h
    else
        c.handlers[T] = Dict(tag => h)
    end
end
