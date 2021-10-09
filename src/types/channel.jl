export DiscordChannel

"""
A [`DiscordChannel`](@ref)'s type. Prefix with `CT_`. See full list
at https://discord.com/developers/docs/resources/channel#channel-object-channel-types
"""
@enum ChannelType begin
    CT_GUILD_TEXT=0
    CT_DM=1
    CT_GUILD_VOICE=2
    CT_GROUP_DM=3
    CT_GUILD_CATEGORY=4
    CT_GUILD_NEWS=5
    CT_GUILD_STORE=6
    UNUSED_API_V9_1=7
    UNUSED_API_V9_2=8
    UNUSED_API_V9_3=9
    CT_GUILD_NEWS_THREAD=10
    CT_GUILD_PUBLIC_THREAD=11
    CT_GUILD_PRIVATE_THREAD=12
    CT_GUILD_STAGE_VOICE=13
end
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
