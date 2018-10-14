mutable struct State
    v::Int                              # Discord API version.
    session_id::String                  # Gateway session ID.
    _trace::Vector{String}              # Guilds the user is in.
    user::Union{User, Nothing}          # Bot user.
    events::Vector{AbstractEvent}       # Events received by the client.
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
end

function State(ttl::Period)
    return State(
        0,         # v
        "",        # session_id
        [],        # _trace
        nothing,   # user
        [],        # events
        TTL(ttl),  # guilds
        TTL(ttl),  # channels
        TTL(ttl),  # users
        TTL(ttl),  # messages
        Dict(),    # presences
        Dict(),    # members
    )
end

function ready(s::State, e::Ready)
    s.v = e.v
    s.session_id = e.session_id
    s._trace = e._trace
    s.user = e.user

    for c in e.private_channels
        # Overwrite here because the data is more recent.
        s.channels[e.id] = e
    end
    for g in e.guilds
        # Don't overwrite anuthing here because these guilds are unavailable.
        if !haskey(s.guilds, g.id)
            s.guilds[g.id] = g
        end
    end
    for p in s.presences
        # Overwrite here because the data is more recent.
        if !haskey(s.presences, p.guild_id)
            s.presences[p.guild_id] = Dict()
        end
        s.guilds[p.guild_id][p.user.id] = p
    end
end
