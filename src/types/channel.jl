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
    topic::Union{String, Nothing, Missing}
    nsfw::Optional{Bool}
    last_message_id::Union{Snowflake, Nothing, Missing}
    bitrate::Optional{Int}
    user_limit::Optional{Int}
    rate_limit_per_user::Optional{Int}
    recipients::Optional{Vector{User}}
    icon::Union{String, Nothing, Missing}
    owner_id::Optional{Snowflake}
    application_id::Optional{Snowflake}
    parent_id::Union{Snowflake, Nothing, Missing}
    last_pin_timestamp::Union{DateTime, Nothing, Missing}  # Not supposed to be nullable.
end
@boilerplate DiscordChannel :constructors :docs :lower :merge :mock
