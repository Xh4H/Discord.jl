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
    errors::Vector{Union{Dict, AbstractEvent}}            # Values which caused errors.
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
        [],        # errors
        Threads.SpinLock(),  # lock
        ttl,       # ttl
    )
end

TimeToLive.TTL(s::State) = TTL(s.ttl)

Base.get(s::State, ::Type; kwargs...) = nothing
Base.get(s::State, ::Type{Guild}; kwargs...) = get(s.guilds, kwargs[:guild], nothing)
Base.get(s::State, ::Type{User}; kwargs...) = get(s.users, kwargs[:user], nothing)
Base.get(s::State, ::Type{Message}; kwargs...) = get(s.messages, kwargs[:message], nothing)
function Base.get(s::State, ::Type{DiscordChannel}; kwargs...)
    return get(get(s.channels, kwargs[:guild], Dict()), kwargs[:channel], nothing)
end
function Base.get(s::State, ::Type{Vector{DiscordChannel}}; kwargs...)
    guild = kwargs[:guild]
    return haskey(s.guilds, guild) ? coalesce(s.guilds[guild].channels, nothing) : nothing
end
function Base.get(s::State, ::Type{Presence}; kwargs...)
    return get(get(s.presences, kwargs[:guild], Dict()), kwargs[:user], nothing)
end
function Base.get(s::State, ::Type{Member}; kwargs...)
    return get(get(s.members, kwargs[:guild], Dict()), kwargs[:user], nothing)
end

Base.put!(s::State, val; kwargs...) = nothing
Base.put!(s::State, g::UnavailableGuild; kwargs...) = insert_or_update!(s.guilds, g)

function Base.put!(s::State, m::Message; kwargs...)
    insert_or_update!(s.messages, m)
    touch(s.channels, m.channel_id)
    touch(s.guilds, m.guild_id)
end

function Base.put!(s::State, g::Guild; kwargs...)
    insert_or_update!(s.guilds, g)

    put!(s, coalesce(g.channels, DiscordChannel[]); kwargs...)

    for m in coalesce(g.members, [])
        put!(s, m; kwargs..., guild=g.id)
    end

    for p in coalesce(g.presences, [])
        put!(s, p; kwargs...)
    end
end

function Base.put!(s::State, ms::Vector{Message}; kwargs...)
    for m in ms
        put!(s, m; kwargs...)
    end
end

function Base.put!(s::State, ch::DiscordChannel; kwargs...)
    insert_or_update!(s.channels, ch)

    for u in coalesce(ch.recipients, [])
        put!(s, u)
    end

    if haskey(s.guilds, ch.guild_id)
        g = s.guilds[ch.guild_id]
        g isa Guild || return
        if ismissing(g.channels)
            s.guilds[ch.guild_id] = @set g.channels = [ch]
        else
            insert_or_update!(g.channels, ch)
        end
    end
end

function Base.put!(s::State, chs::Vector{DiscordChannel}; kwargs...)
    for ch in chs
        put!(s, ch; kwargs...)
    end
end

function Base.put!(s::State, u::User; kwargs...)
    insert_or_update!(s.users, u)

    for ms in values(s.members)
        if haskey(ms, u.id)
            m = ms[u.id]
            m = @set m.user = merge(m.user, u)
            ms[u.id] = m
        end
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
        g isa Guild || return
        if ismissing(g.presences)
            s.guilds[p.guild_id] = @set g.presences = [p]
        else
            insert_or_update!(g.presences, p; key=x -> x.user.id)
        end
    end

    # TODO: Should we refresh the expiries or users/members/guilds here?
    # Probably not, since that would effectively keep all guild loaded at all times.
end

function Base.put!(s::State, m::Member; kwargs...)
    ismissing(m.user) && return
    guild = kwargs[:guild]

    if !haskey(s.members, guild)
        s.members[guild] = TTL(s)
    end
    ms = s.members[guild]
    insert_or_update!(ms, m; key=x -> x.user.id)

    insert_or_update!(s.users, m.user.id, m.user)

    if haskey(s.guilds, guild)
        g = s.guilds[guild]
        g isa Guild || return
        if ismissing(g.members)
            s.guilds[guild] = @set g.members = [m]
        else
            insert_or_update!(g.members, m; key=x -> x.user.id)
        end
    end
end

function Base.put!(s::State, r::Role; kwargs...)
    guild = kwargs[:guild]
    haskey(s.guilds, guild) || return
    g = s.guilds[guild]
    g isa Guild || return

    if ismissing(g.roles)
        s.guilds[guild] = @set g.roles = [r]
    else
        insert_or_update!(g.roles, r)
    end
end

# This handles emojis being added to a guild.
function Base.put!(s::State, es::Vector{Emoji}; kwargs...)
    guild = kwargs[:guild]

    if haskey(s.guilds, guild)
        g = s.guilds[guild]
        g isa Guild || return
        g = @set g.emojis = es
        s.guilds[guild] = g
    end
end

# This handles a single emoji being added as a reaction.
function Base.put!(s::State, e::Emoji; kwargs...)
    message = kwargs[:message]
    user = kwargs[:user]

    locked(s.lock) do
        haskey(s.messages, message) || return
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
end

insert_or_update!(d, k, v; kwargs...) = d[k] = haskey(d, k) ? merge(d[k], v) : v
function insert_or_update!(d::Vector, k, v; key::Function=x -> x.id)
    idx = findfirst(x -> key(x) == k, d)
    if idx === nothing
        push!(d, v)
    else
        d[idx] = merge(d[idx], v)
    end
end
function insert_or_update!(d, v; key::Function=x -> x.id)
    insert_or_update!(d, key(v), v; key=key)
end
