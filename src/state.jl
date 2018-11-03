mutable struct State
    v::Int                              # Discord API version.
    session_id::String                  # Gateway session ID.
    _trace::Vector{String}              # Guilds the user is in.
    user::Union{User, Nothing}          # Bot user.
    guilds::TTL{Snowflake, AbstractGuild}     # Guild ID -> guild.
    channels::TTL{Snowflake, DiscordChannel}  # Channel ID -> channel.
    users::TTL{Snowflake, User}               # User ID -> user.
    messages::TTL{Snowflake, Message}         # Message ID -> message.
    presences::Dict{Snowflake, TTL{Snowflake, Presence}}  # Guild ID -> user ID -> presence.
    members::Dict{Snowflake, TTL{Snowflake, Member}}      # Guild ID -> member ID -> member.
    lock::Threads.AbstractLock  # Internal lock.
    ttl::Period                 # TTL for creating caches without a Client.
end

function State(ttl::Period)
    return State(
        0,         # v
        "",        # session_id
        [],        # _trace
        nothing,   # user
        TTL(ttl),  # guilds
        TTL(ttl),  # channels
        TTL(ttl),  # users
        TTL(ttl),  # messages
        Dict(),    # presences
        Dict(),    # members
        Threads.SpinLock(),  # lock
        ttl,       # default_ttl
    )
end

TimeToLive.TTL(s::State) = TTL(s.ttl)

Base.get(s::State, ::Type; kwargs...) = nothing
Base.get(s::State, ::Type{Guild}; kwargs...) = get(s.guilds, kwargs[:guild], nothing)
Base.get(s::State, ::Type{User}; kwargs...) = get(s.users, kwargs[:user], nothing)
Base.get(s::State, ::Type{Message}; kwargs...) = get(s.messages, kwargs[:message], nothing)
function Base.get(s::State, ::Type{DiscordChannel}; kwargs...)
    return get(get(c.channels, kwargs[:guild], Dict()), kwargs[:channel], nothing)
end
function Base.get(s::State, ::Type{Presence}; kwargs...)
    return get(get(s.presences, kwargs[:guild], Dict()), kwargs[:user], nothing)
end
function Base.get(s::State, ::Type{Member}; kwargs...)
    return get(get(s.members, kwargs[:guild], Dict()), kwargs[:user], nothing)
end

Base.put!(s::State, val; kwargs...) = nothing

function Base.put!(s::State, g::Guild; kwargs...)
    insert_or_update!(s.guilds, g)

    for ch in coalesce(g.channels, [])
        put!(c.state, ch)
    end

    for m in coalesce(g.members, [])
        put!(c.state, m; guild=g.id)
    end

    for p in coalesce(g.presences, [])
        put!(c.state, p)
    end
end

function Base.put!(s::State, ch::DiscordChannel; kwargs...)
    if haskey(s.guilds, ch.guild_id)
        g = s.guilds[ch.guild_id]
        if ismissing(g.channels)
            @set g.channels = [ch]
        else
            insert_or_update!(g.channels, ch)
        end
    end

    if !haskey(s.channels, ch.guild_id)
        s.channels[ch.guild_id] = TTL(s)
    end
    insert_or_update!(s.channels, ch)
end

function Base.put!(s::State, u::User; kwargs...)
    insert_or_update!(s.users, u)

    for ms in filter(ms -> haskey(ms, u.id), s.members)
        ms[u.id] = merge(ms[u.id], u)
    end
end

function Base.put!(s::State, p::Presence; kwargs...)
    ismissing(p.guild_id) && return

    if !haskey(s.presences, p.guild_id)
        s.presences[p.guild_id] = TTL(s)
    end
    insert_or_update!(s.presences[p.guild_id], p.user.id, p)

    if haskey(s.guilds, p.guild_id)
        g = s.guilds[p.guild_id]
        if ismissing(g.presences)
            @set g.presences = [p]
        else
            insert_or_update!(g.presences, p; accessor=x -> x.user.id)
        end
    end
end

function Base.put!(s::State, es::Vector{Emoji}; kwargs...)
    guild = kwargs[:guild]

    if haskey(s.guilds, guild) && s.guilds[guild] isa Guild
        @set s.guilds.emojis = es
    end
end

function Base.put!(s::State, m::Member; kwargs...)
    ismissing(m.user) && return
    guild = kwargs[:guild]

    if !haskey(s.members, guild)
        s.members[guild] = TTL(s)
    end
    ms = s.members[guild]
    insert_or_update!(ms, m; accessor=x -> x.user.id)

    insert_or_upate!(s.users, m.user.id, m.user)
end

function Base.put!(s::State, r::Role; kwargs...)
    guild = kwargs[:guild]
    haskey(s.guilds, guild) || return
    g = s.guilds[guild]

    if ismissing(g.roles)
        @set g.roles = [r]
    else
        push!(g.roles, r)
    end
    touch(s.guilds, guild)
end

function Base.put!(s::State, e::Emoji; kwargs...)
    message = kwargs[:message]
    user = kwargs[:user]

    locked(s.lock) do
        haskey(s.messages, message) || return
        m = s.messages[message]
        isclient = !ismissing(s.user) && s.user.id == user
        if ismissing(m.reactions)
            m = @set m.reactions = [Reaction(1, isclient, e)]
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
    touch(s.messages, message)
end

insert_or_update!(d, k, v; kwargs...) = d[k] = haskey(d, k) ? merge(d[k], v) : v
function insert_or_update!(d::Vector, k, v; accessor::Function=x -> x.id)
    idx = findfirst(x -> accessor(x) == k, d)
    if idx === nothing
        push!(d, v)
    else
        d[idx] = merge(d[idx], v)
    end
end
function insert_or_update!(d, v; accessor::Function=x -> x.id)
    insert_or_update!(d, accessor(v), v; accessor=accessor)
end
