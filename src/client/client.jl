export Client,
    me,
    enable_cache!,
    disable_cache!,
    add_handler!,
    delete_handler!,
    DEFAULT_HANDLER_TAG

include("limiter.jl")
include("state.jl")

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

# An event handler.
abstract type AbstractHandler{T<:AbstractEvent} end

donothing(args...; kwargs...) = nothing
alwaystrue(args...; kwargs...) = true
Base.eltype(::AbstractHandler{T}) where T = T
Base.notify(::AbstractHandler) = nothing
Base.wait(::AbstractHandler) = nothing
func(::AbstractHandler) = donothing
pred(::AbstractHandler) = alwaystrue
expiry(::AbstractHandler) = nothing
dec!(::AbstractHandler) = nothing
isexpired(h::AbstractHandler) = false

mutable struct Handler{T} <: AbstractHandler{T}
    func::Function
    pred::Function
    remaining::Union{Int, Nothing}
    expiry::Union{DateTime, Nothing}
    cond::Condition

    function Handler{T}(
        func::Function,
        pred::Function,
        remaining::Union{Int, Nothing},
        expiry::Union{DateTime, Nothing},
    ) where T <: AbstractEvent
        return new{T}(func, pred, remaining, expiry, Condition())
    end
    function Handler{T}(
        func::Function,
        pred::Function,
        remaining::Union{Int, Nothing},
        expiry::Period,
    ) where T <: AbstractEvent
        return new{T}(func, pred, remaining, now() + expiry, Condition())
    end
end

func(h::Handler) = h.func
pred(h::Handler) = h.pred
expiry(h::Handler) = h.expiry
Base.notify(h::Handler) = notify(h.cond)
dec!(h::Handler) = h.remaining isa Int && (h.remaining -= 1)

function isexpired(h::Handler)
    return if h.remaining isa Int && h.remaining <= 0
        true
    elseif h.expiry isa DateTime && now() > h.expiry
        true
    else
        false
    end
end

function Base.wait(h::Handler)
    if h.remaining === nothing && h.expiry === nothing
        throw(ArgumentError("Can't wait for a handler with no expiry"))
    end
    h.remaining isa Int && h.remaining > 0 && wait(h.cond)
    h.expiry isa DateTime && h.expiry > now() && sleep(h.expiry - now())
end

# A versioned WebSocket connection.
struct Conn
    io
    v::Int
end

"""
    Client(
        token::String;
        presence::Union{Dict, NamedTuple}=Dict(),
        ttls::$TTLDict=Dict(),
        version::Int=$API_VERSION,
    ) -> Client

A Discord bot. `Client`s can connect to the gateway, respond to events, and make REST API
calls to perform actions such as sending/deleting messages, kicking/banning users, etc.

# Keywords
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
    token::String       # Bot token, always with a leading "Bot ".
    hb_interval::Int    # Milliseconds between heartbeats.
    hb_seq::Union{Int, Nothing}  # Sequence value sent by Discord for resuming.
    last_hb::DateTime   # Last heartbeat send.
    last_ack::DateTime  # Last heartbeat ack.
    ttls::TTLDict       # Cache lifetimes.
    version::Int        # Discord API version.
    state::State        # Client state, cached data, etc.
    shards::Int         # Number of shards in use.
    shard::Int          # Client's shard index.
    limiter::Limiter    # Rate limiter.
    ready::Bool         # Client is connected and authenticated.
    use_cache::Bool     # Whether or not to use the cache for REST ops.
    handlers::Dict{Type{<:AbstractEvent}, Dict{Symbol, AbstractHandler}}  # Event handlers.
    conn::Conn          # WebSocket connection.

    function Client(
        token::String;
        presence::Union{Dict, NamedTuple}=Dict(),
        ttls::TTLDict=TTLDict(),
        version::Int=API_VERSION,
    )
        token = startswith(token, "Bot ") ? token : "Bot $token"
        ttls = merge(DEFAULT_TTLS, ttls)
        state = State(presence, ttls)

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
            Dict(),       # handlers
            # conn left undef, it gets assigned in open.
        )

        add_handler!(c, Defaults; tag=DEFAULT_HANDLER_TAG)
        return c
    end
end

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
        expiry::Union{Period, Nothing}=nothing,
    )
    add_handler!(
        func::Function,
        c::Client,
        T::Type{<:AbstractEvent};
        tag::Symbol=gensym(),
        n::Union{Int, Nothing}=nothing,
        expiry::Union{Period, Nothing}=nothing,
    )

Add an event handler. `func` should be a function which takes two arguments: A
[`Client`](@ref) and an [`AbstractEvent`](@ref) (or a subtype). The handler is appended to
the event's current handlers. You can also define a single handler for multiple event types
by using a `Union`. `do` syntax is also accepted.

# Keywords
- `tag::Symbol=gensym()`: A label for the handler, which can be used to remove it with
  [`delete_handler!`](@ref).
- `pred::Function=alwaystrue`: A predicate function. The handler will only run if this
  function returns `true`. Its signature should match that of `func`.
- `n::Union{Int, Nothing}=nothing`: The number of times to run the handler before expiring.
  if left unset, the handler runs an infinite number of times. Can be used in conjunction
  with `expiry`.
- `expiry::Union{Period, Nothing}=nothing`: The handler's time expiry. If left unset,
  the handler stays active forever. Can be used in conjunction with `n`.
- `block::Bool=false`: If set, block until the handler expires. You must set `expiry` or
  `n` along with this keyword.

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
    expiry::Union{Period, Nothing}=nothing,
    block::Bool=false,
)
    if T isa Union
        block && throw(ArgumentError("Can only block for one event at a time"))
        add_handler!(c, T.a, func; tag=tag, pred=pred, expiry=expiry)
        add_handler!(c, T.b, func; tag=tag, pred=pred, expiry=expiry)
        return
    end

    h = Handler{T}(func, pred, n, expiry)

    if !hasmethod(func, (Client, T))
        throw(ArgumentError("Handler function must accept (::Client, ::$T)"))
    end
    if !hasmethod(pred, (Client, T))
        throw(ArgumentError("Predicate function must accept (::Client, ::$T)"))
    end
    if isexpired(h)
        throw(ArgumentError("Can't add a handler that's already expired"))
    end

    if haskey(c.handlers, T)
        c.handlers[T][tag] = h
    else
        c.handlers[T] = Dict(tag => h)
    end

    block && wait(h)
    return nothing
end

function add_handler!(
    func::Function,
    c::Client,
    T::Type{<:AbstractEvent};
    tag::Symbol=gensym(),
    pred::Function=alwaystrue,
    n::Union{Int, Nothing}=nothing,
    expiry::Union{Period, Nothing}=nothing,
    block::Bool=false,
)
    return add_handler!(c, T, func; tag=tag, pred=pred, n=n, expiry=expiry, block=block)
end

"""
    add_handler!(
        c::Client,
        m::Module;
        tag::Symbol=gensym(),
        pred::Function=alwaystrue,
        n::Union{Int, Nothing}=nothing,
        expiry::Union{Period, Nothing}=nothing,
    )

Add all of the event handlers defined in a module. Any function you wish to use as a
handler must be exported. Only functions with correct type signatures (see above) are used.

!!! note
    If you specify a `tag`, `pred`, `n`, and/or `expiry`, it's applied to all of the
    handlers in the module. For example, if you add two handlers for the same event type
    with the same tag, one of them will be immediately overwritten.
"""
function add_handler!(
    c::Client,
    m::Module;
    tag::Symbol=gensym(),
    pred::Function=alwaystrue,
    n::Union{Int, Nothing}=nothing,
    expiry::Union{Period, Nothing}=nothing,
)
    for f in filter(f -> f isa Function, map(n -> getfield(m, n), names(m)))
        for m in methods(f).ms
            ts = m.sig.types[2:end]
            length(m.sig.types) == 3 || continue
            if m.sig.types[2] === Client && m.sig.types[3] <: AbstractEvent
                add_handler!(c, m.sig.types[3], f; tag=tag, pred=pred, n=n, expiry=expiry)
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
    handlers = get(c.handlers, T, Dict())
    if haskey(handlers, tag)
        notify(handlers[tag])
        delete!(handlers, tag)
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
    isdefined(c, :conn) && push!(kws, :conn => c.conn.v)

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
