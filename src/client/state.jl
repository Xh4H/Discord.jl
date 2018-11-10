mutable struct State
    v::Int                              # Discord API version.
    session_id::String                  # Gateway session ID.
    _trace::Vector{String}              # Guilds the user is in.
    user::Union{User, Nothing}          # Bot user.
    login_presence::Dict                # Bot user's presence upon connection.
    guilds::TTL{Snowflake, AbstractGuild}     # Guild ID -> guild.
    channels::TTL{Snowflake, DiscordChannel}  # Channel ID -> channel.
    users::TTL{Snowflake, User}               # User ID -> user.
    messages::TTL{Snowflake, Message}         # Message ID -> message.
    presences::Dict{Snowflake, TTL{Snowflake, Presence}}  # Guild ID -> user ID -> presence.
    members::Dict{Snowflake, TTL{Snowflake, Member}}      # Guild ID -> member ID -> member.
    errors::Vector{Union{Dict, AbstractEvent}}            # Values which caused errors.
    lock::Threads.AbstractLock    # Internal lock.
    ttls::TTLDict                 # TTLs for creating caches without a Client.
end

State(presence::NamedTuple, ttls::TTLDict) = State(Dict(pairs(presence)), ttls)
function State(presence::Dict, ttls::TTLDict)
    presence = merge(Dict(
        "since" => nothing,
        "game" => nothing,
        "status" => PS_ONLINE,
        "afk" => false,
    ), Dict(string(k) => v for (k, v) in presence))

    return State(
        0,                          # v
        "",                         # session_id
        [],                         # _trace
        nothing,                    # user
        presence,                   # login_presence
        TTL(ttls[Guild]),           # guilds
        TTL(ttls[DiscordChannel]),  # channels
        TTL(ttls[User]),            # users
        TTL(ttls[Message]),         # messages
        Dict(),                     # presences
        Dict(),                     # members
        [],                         # errors
        Threads.SpinLock(),         # lock
        ttls,                       # ttls
    )
end

TimeToLive.TTL(s::State, ::Type{T}) where T = TTL(get(s.ttls, T, nothing))

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
        filter(i -> haskey(s.channels, i), collect(s.guilds[guild].djl_channels)),
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
        filter(ch -> haskey(s.channels, ch), collect(g.djl_channels)),
    )
    ms = get(s.members, g.id, Dict())
    g = @set g.members = map(
        i -> get(s, Member; guild=g.id, user=i),
        filter(i -> haskey(ms, i), collect(coalesce(g.djl_users, Member[]))),
    )
    ps = get(s.presences, g.id, Dict())
    g = @set g.presences = map(
        i -> get(s, Presence; guild=g.id, user=i),
        filter(i -> haskey(ps, i), collect(coalesce(g.djl_users, Presence[]))),
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
    users = map(m -> m.user.id, filter(m -> m.user !== nothing, ms))
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
    if ismissing(ch.guild_id) && haskey(kwargs, :guild)
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

    haskey(s.presences, guild) || (s.presences[guild] = TTL(s, Presence))
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
    haskey(s.members, guild) || (s.members[guild] = TTL(s, Member))
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

    locked(s.lock) do
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
                r = @set r.me = r.me | isclient  # TODO: |= (Setfield#55).
                r = @set r.emoji = merge(r.emoji, e)
                m.reactions[idx] = r
            end
        end
    end

    return e
end

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
