@enum ChannelType CT_GUILD_TEXT CT_DM CT_GUILD_VOICE CT_GROUP_DM CT_GUILD_CATEGORY

# TODO: Parametric DiscordChannel based on ChannelType.

"""
A Discord channel.
More details [here](https://discordapp.com/developers/docs/resources/channel#channel-object).
Note: The name `Channel` is already used, hence the prefix.
"""
@from_dict struct DiscordChannel
    id::Snowflake
    type::ChannelType
    guild_id::Union{Snowflake, Missing}
    position::Union{Int, Missing}
    permission_overwrites::Union{Vector{Overwrite}, Missing}
    name::Union{String, Missing}
    topic::Union{String, Nothing, Missing}
    nsfw::Union{Bool, Missing}
    last_message_id::Union{Snowflake, Nothing, Missing}
    bitrate::Union{Int, Missing}
    user_limit::Union{Int, Missing}
    rate_limit_per_user::Union{Int, Missing}
    recipients::Union{Vector{User}, Missing}
    icon::Union{String, Nothing, Missing}
    owner_id::Union{Snowflake, Missing}
    application_id::Union{Snowflake, Missing}
    parent_id::Union{Snowflake, Nothing, Missing}
    last_pin_timestamp::Union{DateTime, Missing}
end
