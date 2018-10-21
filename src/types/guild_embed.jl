"""
A [`Guild`](@ref) embed.
More details [here](https://discordapp.com/developers/docs/resources/guild#guild-embed-object).
"""
@from_dict struct GuildEmbed
    enabled::Bool
    channel_id::Union{Snowflake, Nothing}
end
