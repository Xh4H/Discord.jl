export GuildEmbed

"""
A [`Guild`](@ref) embed.
More details [here](https://discordapp.com/developers/docs/resources/guild#guild-embed-object).
"""
struct GuildEmbed
    enabled::Bool
    channel_id::Nullable{Snowflake}
end
@boilerplate GuildEmbed :constructors :docs :lower :merge :mock
