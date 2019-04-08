export DiscordChannel

"""
A [`DiscordChannel`](@ref)'s type. Available values are `CT_GUILD_TEXT`, `CT_DM`,
`CT_GUILD_VOICE`, `CT_GROUP_DM`, `CT_GUILD_CATEGORY`, `CT_GUILD_NEWS` and `CT_GUILD_STORE`.
"""
@enum ChannelType CT_GUILD_TEXT CT_DM CT_GUILD_VOICE CT_GROUP_DM CT_GUILD_CATEGORY CT_GUILD_NEWS CT_GUILD_STORE
@boilerplate ChannelType :export :lower

"""
A Discord channel.
More details [here](https://discordapp.com/developers/docs/resources/channel#channel-object).

Note: The name `Channel` is already used, hence the prefix.
"""
struct DiscordChannel
    id::Snowflake
    type::ChannelType
    guild_id::Optional{Snowflake}
    position::Optional{Int}
    permission_overwrites::Optional{Vector{Overwrite}}
    name::Optional{String}
    topic::OptionalNullable{String}
    nsfw::Optional{Bool}
    last_message_id::OptionalNullable{Snowflake}
    bitrate::Optional{Int}
    user_limit::Optional{Int}
    rate_limit_per_user::Optional{Int}
    recipients::Optional{Vector{User}}
    icon::OptionalNullable{String}
    owner_id::Optional{Snowflake}
    application_id::Optional{Snowflake}
    parent_id::OptionalNullable{Snowflake}
    last_pin_timestamp::OptionalNullable{DateTime}  # Not supposed to be nullable.
end
@boilerplate DiscordChannel :constructors :docs :lower :merge :mock
