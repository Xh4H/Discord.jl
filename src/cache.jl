mutable struct Cache
    guilds::Dict{Snowflake, AbstractGuild}     # Guild ID -> guild.
    channels::Dict{Snowflake, DiscordChannel}  # Channel ID -> channel.
    users::Dict{Snowflake, User}               # User ID -> user.
    # Guild ID -> member ID -> member.
    # If a member appears with a user object attached, then it's stored by user ID.
    # If the user field is missing, the member is appended to the missing key's value.
    members::Dict{Snowflake, Dict{Union{Snowflake, Missing}, Union{Member, Vector{Member}}}}
    state::Union{State, Nothing}
    events::Vector{AbstractEvent}  # Events received by the client.
end

Cache() = Cache(Dict(), Dict(), Dict(), Dict(), nothing, [])
