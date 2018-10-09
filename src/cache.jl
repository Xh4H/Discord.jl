mutable struct Cache
    guilds::Dict{Snowflake, AbstractGuild}             # Guild ID -> guild.
    channels::Dict{Snowflake, DiscordChannel}          # Channel ID -> channel.
    users::Dict{Snowflake, User}                       # User ID -> user.
    members::Dict{Snowflake, Dict{Snowflake, Member}}  # Guild ID -> member ID -> member.
    state::Union{State, Nothing}
    events::Vector{AbstractEvent}
end

Cache() = Cache(Dict(), Dict(), Dict(), Dict(), nothing, [])
