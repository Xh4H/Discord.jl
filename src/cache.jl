struct Cache
    guilds::Dict{Snowflake, AbstractGuild}
    channels::Dict{Snowflake, DiscordChannel}
    users::Dict{Snowflake, User}
    members::Dict{Snowflake, Member}
    state::Dict{String, Any}
end

Cache() = Cache(Dict(), Dict(), Dict(), Dict(), Dict())
