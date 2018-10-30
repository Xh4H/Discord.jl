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
    )
end
