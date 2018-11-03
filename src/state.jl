mutable struct State
    v::Int                              # Discord API version.
    session_id::String                  # Gateway session ID.
    _trace::Vector{String}              # Guilds the user is in.
    user::Union{User, Nothing}          # Bot user.
    guilds::TTL{Snowflake, AbstractGuild}     # Guild ID -> guild.
    channels::TTL{Snowflake, DiscordChannel}  # Channel ID -> channel.
    users::TTL{Snowflake, User}               # User ID -> user.
    messages::TTL{Snowflake, Message}         # Message ID -> message.
    # Guild ID -> user ID -> presence.
    # If a presence appears with a guild ID attached, then it's stored in that guild.
    # If the guild ID field is missing, the presence is appended to the missing key's value.
    presences::Dict{Union{Snowflake, Missing}, TTL{Snowflake, Presence}}
    # Guild ID -> member ID -> member.
    # If a member appears with a user object attached, then it's stored by user ID.
    # If the user field is missing, the member is appended to the missing key's value.
    # Note: the vector of members with missing user IDs is treated as a single object
    # by the TTL, so they'll all be cleared at the same time.
    members::Dict{Snowflake, TTL{Union{Snowflake, Missing}, Union{Member, Vector{Member}}}}
    lock::Threads.AbstractLock
    default_ttl::Period
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

TimeToLive.TTL(s::State, ttl=s.default_ttl) = TTL(ttl)

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

Base.put!(s::State, val) = nothing

insert_or_update!(d, k, v) = d[k] = haskey(d, k) ? merge(d[k], v) : v
function insert_or_update!(d::Vector, k, v)
    idx = findfirst(x -> x.id == k, d)
    if idx === nothing
        push!(d, v)
    else
        d[idx] = merge(d[idx], v)
    end
end
