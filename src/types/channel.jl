@enum ChannelType GUILD_TEXT DM GUILD_VOICE GROUP_DM GUILD_CATEGORY

# TODO: Parametric DiscordChannel based on ChannelType.

"""
A Discord channel.
More details [here](https://discordapp.com/developers/docs/resources/channel#channel-object).
Note: The name `Channel` is already used, hence the prefix.
"""
@from_dict struct DiscordChannel
    id::Snowflake
    type::ChannelType
    guild_id::Union{Snowflake, Nothing}
    position::Union{Int, Nothing}
    permission_overwrites::Union{Vector{Overwrite}, Nothing}
    name::Union{String, Nothing}
    topic::Union{String, Nothing, Missing}
    nsfw::Union{Bool, Nothing}
    last_message_id::Union{Snowflake, Nothing, Missing}
    bitrage::Union{Int, Nothing}
    user_limit::Union{Int, Nothing}
    rate_limit_per_user::Union{Int, Nothing}
    recipients::Union{Vector{User}, Nothing}
    icon::Union{String, Nothing, Missing}
    owner_id::Union{Snowflake, Nothing}
    application_id::Union{Snowflake, Nothing}
    parent_id::Union{Snowflake, Nothing, Missing}
    last_pin_timestamp::Union{DateTime, Nothing}
end
