export CacheForever,
    CacheNever,
    CacheTTL,
    CacheLRU,
    CacheFilter

# TODO: Strategy composition, e.g. TTL eviction with filtered insertion.

"""
A method of handling cache insertion and eviction.
"""
abstract type CacheStrategy end

"""
    CacheForever() -> CacheForever

Store everything and never evict items from the cache.
"""
struct CacheForever <: CacheStrategy end

"""
    CacheNever() -> CacheNever

Don't store anything in the cache.
"""
struct CacheNever <: CacheStrategy end

"""
    CacheTTL(ttl::Period) -> CacheTTL

Evict items from the cache after `ttl` has elapsed.
"""
struct CacheTTL <: CacheStrategy
    ttl::Period
end

"""
    CacheLRU(size::Int) -> CacheLRU

Evict the least recently used item from the cache when there are more than `size` items.
"""
struct CacheLRU <: CacheStrategy
    size::Int
end

"""
    CacheFilter(f::Function) -> CacheFilter

Only store value `v` at key `k` if `f(v) === true` (`k` is always `v.id`).
"""
struct CacheFilter <: CacheStrategy
    f::Function
end

# A dict-like object with a caching strategy.
struct Store{D, S <: CacheStrategy}
    data::D
    strat::S

    Store(d::D, s::CacheStrategy) where D = new{D, typeof(s)}(d, s)
end

Store(::CacheForever, V::Type) = Store(Dict{Snowflake, V}(), CacheForever())
Store(::CacheNever, V::Type) = Store(Dict{Snowflake, V}(), CacheNever())
Store(s::CacheTTL, V::Type) = Store(TTL{Snowflake, V}(s.ttl), s)
Store(s::CacheLRU, V::Type) = Store(LRU{Snowflake, V}(s.size), s)
Store(s::CacheFilter, V::Type) = Store(Dict{Snowflake, V}(), s)

Base.eltype(s::Store) = eltype(s.data)
Base.get(s::Store, key, default) = get(s.data, key, default)
Base.getindex(s::Store, key) = s.data[key]
Base.haskey(s::Store, key) = haskey(s.data, key)
Base.isempty(s::Store) = isempty(s.data)
Base.keys(s::Store) = keys(s.data)
Base.values(s::Store) = values(s.data)
Base.length(s::Store) = length(s.data)
Base.iterate(s::Store) = iterate(s.data)
Base.iterate(s::Store, i) = iterate(s.data, i)
Base.touch(s::Store, k) = nothing
Base.delete!(s::Store, key) = (delete!(s.data, key); s)
Base.empty!(s::Store) = (empty!(s.data); s)
Base.filter!(f, s::Store) = (filter!(s.data); s)
Base.setindex!(s::Store, value, key) = (setindex!(s.data, value, key); s)

Base.touch(s::Store{D, CacheTTL}, key) where D = touch(s.data, key)
Base.setindex!(s::Store{D, CacheNever}, value, key) where D = s
function Base.setindex!(s::Store{D, CacheFilter}, value, key) where D
    try
        s.strat.f(value) === true && setindex!(s.data, value, key)
    catch
        # TODO: Log this?
    end
    return s
end

# Container for all client state.
mutable struct State
    v::Int                                 # Discord API version.
    session_id::String                     # Gateway session ID.
    _trace::Vector{String}                 # Servers (not guilds) connected to.
    user::Nullable{User}                   # Bot user.
    guilds::Store                          # Guild ID -> guild.
    channels::Store                        # Channel ID -> channel.
    users::Store                           # User ID -> user.
    messages::Store                        # Message ID -> message.
    presences::Dict{Snowflake, Store}      # Guild ID -> user ID -> presence.
    members::Dict{Snowflake, Store}        # Guild ID -> member ID -> member.
    sem::Base.Semaphore                    # Internal mutex.
    strats::Dict{DataType, CacheStrategy}  # Caching strategies per type.
end

function State(strats::Dict{DataType, <:CacheStrategy})
    return State(
        0,        # v
        "",       # session_id
        [],       # _trace
        nothing,  # user
        Store(strats[Guild], AbstractGuild),            # guilds
        Store(strats[DiscordChannel], DiscordChannel),  # channels
        Store(strats[User], User),                      # users
        Store(strats[Message], Message),                # messages
        Dict(),              # presences
        Dict(),              # members
        Base.Semaphore(1),   # sem
        strats,              # strats
    )
end

Store(s::State, T::Type) = Store(get(s.strats, T, CacheForever()), T)

# Base.get retrieves a value of a given type from the cache, or returns nothing.

Base.get(s::State, ::Type; kwargs...) = nothing
Base.get(s::State, ::Type{User}; kwargs...) = get(s.users, kwargs[:user], nothing)
Base.get(s::State, ::Type{Message}; kwargs...) = get(s.messages, kwargs[:message], nothing)

# Get a single channel.
function Base.get(s::State, ::Type{DiscordChannel}; kwargs...)
    return get(s.channels, kwargs[:channel], nothing)
end

# Get all the channels of a guild.
function Base.get(s::State, ::Type{Vector{DiscordChannel}}; kwargs...)
    guild = kwargs[:guild]
    haskey(s.guilds, guild) || return nothing

    channels = map(
        i -> s.channels[i],
        Iterators.filter(i -> haskey(s.channels, i), collect(s.guilds[guild].djl_channels)),
    )
    return isempty(channels) ? nothing : channels
end

function Base.get(s::State, ::Type{Presence}; kwargs...)
    guild = kwargs[:guild]
    haskey(s.presences, guild) || return nothing
    return get(s.presences[guild], kwargs[:user], nothing)
end

function Base.get(s::State, ::Type{Guild}; kwargs...)
    haskey(s.guilds, kwargs[:guild]) || return nothing
    g = s.guilds[kwargs[:guild]]

    # Guilds are stored with missing channels, members, and presences.
    g = @set g.channels = map(
        ch -> s.channels[ch],
        Iterators.filter(ch -> haskey(s.channels, ch), collect(g.djl_channels)),
    )
    g = @set g.djl_channels = missing
    ms = get(s.members, g.id, Dict())
    g = @set g.members = map(
        i -> get(s, Member; guild=g.id, user=i),
        Iterators.filter(i -> haskey(ms, i), collect(coalesce(g.djl_users, Member[]))),
    )
    ps = get(s.presences, g.id, Dict())
    g = @set g.presences = map(
        i -> get(s, Presence; guild=g.id, user=i),
        Iterators.filter(i -> haskey(ps, i), collect(coalesce(g.djl_users, Presence[]))),
    )
    g = @set g.djl_users = missing

    return g
end

function Base.get(s::State, ::Type{Member}; kwargs...)
    # Members are stored with missing user.
    haskey(s.members, kwargs[:guild]) || return nothing
    guild = s.members[kwargs[:guild]]

    haskey(guild, kwargs[:user]) || return nothing
    member = guild[kwargs[:user]]

    haskey(s.users, kwargs[:user]) || return member  # With a missing user field.
    user = s.users[kwargs[:user]]
    return @set member.user = user
end

function Base.get(s::State, ::Type{Role}; kwargs...)
    haskey(s.guilds, kwargs[:guild]) || return nothing
    roles = coalesce(s.guilds[kwargs[:guild]].roles, Role[])
    idx = findfirst(r -> r.id == kwargs[:role], roles)
    return idx === nothing ? nothing : roles[idx]
end

# Base.put! inserts a value into the cache, and returns the updated value.

Base.put!(s::State, val; kwargs...) = val
Base.put!(s::State, g::UnavailableGuild; kwargs...) = insert_or_update!(s.guilds, g)
Base.put!(s::State, ms::Vector{Member}; kwargs...) = map(m -> put!(s, m; kwargs...), ms)
Base.put!(s::State, u::User; kwargs...) = insert_or_update!(s.users, u)

function Base.put!(s::State, m::Message; kwargs...)
    if ismissing(m.guild_id) && haskey(s.channels, m.channel_id)
        m = @set m.guild_id = s.channels[m.channel_id].guild_id
    end

    insert_or_update!(s.messages, m)
    touch(s.channels, m.channel_id)
    touch(s.guilds, m.guild_id)

    return m
end

function Base.put!(s::State, g::Guild; kwargs...)
    # Replace members and presences with IDs that can be looked up later.
    ms = coalesce(g.members, Member[])
    ps = coalesce(g.presences, Presence[])
    users = map(m -> m.user.id, Iterators.filter(m -> m.user !== nothing, ms))
    unique!(append!(users, map(p -> p.user.id, ps)))
    g = @set g.members = missing
    g = @set g.presences = missing
    g = @set g.djl_users = Set(users)
    chs = coalesce(g.channels, DiscordChannel[])
    channels = map(ch -> ch.id, chs)
    g = @set g.djl_channels = Set(channels)
    g = @set g.channels = missing

    insert_or_update!(s.guilds, g)
    put!(s, chs; kwargs..., guild=g.id)
    foreach(m -> put!(s, m; kwargs..., guild=g.id), ms)
    foreach(p -> put!(s, p; kwargs..., guild=g.id), ps)

    return get(s, Guild; guild=g.id)
end

function Base.put!(s::State, ms::Vector{Message}; kwargs...)
    return map(m -> put!(s, m; kwargs...), ms)
end

function Base.put!(s::State, ch::DiscordChannel; kwargs...)
    if ismissing(ch.guild_id) && get(kwargs, :guild, nothing) !== nothing
        ch = @set ch.guild_id = kwargs[:guild]
    end

    foreach(u -> put!(s, u; kwargs...), coalesce(ch.recipients, User[]))
    haskey(s.guilds, ch.guild_id) && push!(s.guilds[ch.guild_id].djl_channels, ch.id)

    return insert_or_update!(s.channels, ch)
end

function Base.put!(s::State, chs::Vector{DiscordChannel}; kwargs...)
    return map(ch -> put!(s, ch; kwargs...), chs)
end

function Base.put!(s::State, p::Presence; kwargs...)
    guild = coalesce(get(kwargs, :guild, missing), p.guild_id)
    ismissing(guild) && return p

    if haskey(s.guilds, guild)
        g = s.guilds[guild]
        g isa Guild && push!(g.djl_users, p.user.id)
    end

    haskey(s.presences, guild) || (s.presences[guild] = Store(s, Presence))
    return insert_or_update!(s.presences[guild], p.user.id, p)
end

function Base.put!(s::State, m::Member; kwargs...)
    ismissing(m.user) && return m
    guild = kwargs[:guild]

    # Members are stored with a missing user field to save memory.
    user = m.user
    m = @set m.user = missing

    # This is a bit ugly, but basically we're updating the member as usual but then
    # filling in its user field at the same time as the user sync.
    haskey(s.members, guild) || (s.members[guild] = Store(s, Member))
    m = insert_or_update!(s.members[guild], user.id, m)
    m = @set m.user = insert_or_update!(s.users, user)

    if haskey(s.guilds, guild)
        g = s.guilds[guild]
        g isa Guild && push!(g.djl_users, user.id)
    end

    return m
end

function Base.put!(s::State, r::Role; kwargs...)
    guild = kwargs[:guild]
    haskey(s.guilds, guild) || return r
    g = s.guilds[guild]
    g isa Guild || return r

    return if ismissing(g.roles)
        s.guilds[guild] = @set g.roles = [r]
        r
    else
        insert_or_update!(g.roles, r)
    end
end

# This handles emojis being added to a guild.
function Base.put!(s::State, es::Vector{Emoji}; kwargs...)
    guild = kwargs[:guild]
    haskey(s.guilds, guild) || return es
    g = s.guilds[guild]
    g isa Guild || return es

    s.guilds[guild] = @set g.emojis = es
    return es
end

# This handles a single emoji being added as a reaction.
function Base.put!(s::State, e::Emoji; kwargs...)
    message = kwargs[:message]
    user = kwargs[:user]
    haskey(s.messages, message) || return e

    withsem(s.sem) do
        m = s.messages[message]
        isclient = !ismissing(s.user) && s.user.id == user
        if ismissing(m.reactions)
            s.messages[message] = @set m.reactions = [Reaction(1, isclient, e)]
        else
            idx = findfirst(r -> r.emoji.name == e.name, m.reactions)
            if idx === nothing
                push!(m.reactions, Reaction(1, isclient, e))
            else
                r = m.reactions[idx]
                r = @set r.count += 1
                r = @set r.me |= isclient
                r = @set r.emoji = merge(r.emoji, e)
                m.reactions[idx] = r
            end
        end
    end

    return e
end

# Insert or update a value in the cache.
insert_or_update!(d, k, v; kwargs...) = d[k] = haskey(d, k) ? merge(d[k], v) : v
function insert_or_update!(d::Vector, k, v; key::Function=x -> x.id)
    idx = findfirst(x -> key(x) == k, d)
    return if idx === nothing
        push!(d, v)
        v
    else
        d[idx] = merge(d[idx], v)
    end
end
function insert_or_update!(d, v; key::Function=x -> x.id)
    insert_or_update!(d, key(v), v; key=key)
end
