export Message

"""
A [`Message`](@ref)'s type.
More details [here](https://discordapp.com/developers/docs/resources/channel#message-object-message-types).
"""
@enum MessageType begin
    MT_DEFAULT
    MT_RECIPIENT_ADD
    MT_RECIPIENT_REMOVE
    MT_CALL
    MT_CHANNEL_NAME_CHANGE
    MT_CHANNEL_ICON_CHANGE
    MT_CHANNEL_PINNED_MESSAGE
    MT_GUILD_MEMBER_JOIN
    MT_USER_PREMIUM_GUILD_SUBSCRIPTION
    MT_USER_PREMIUM_GUILD_SUBSCRIPTION_TIER_1
    MT_USER_PREMIUM_GUILD_SUBSCRIPTION_TIER_2
    MT_USER_PREMIUM_GUILD_SUBSCRIPTION_TIER_3
    MT_CHANNEL_FOLLOW_ADD
end
@boilerplate MessageType :export :lower

"""
A [`Message`](@ref)'s activity type.
More details [here](https://discordapp.com/developers/docs/resources/channel#message-object-message-activity-types).
"""
@enum MessageActivityType MAT_JOIN MAT_SPECTATE MAT_LISTEN MAT_JOIN_REQUEST
@boilerplate MessageActivityType :export :lower

"""
A [`Message`](@ref) activity.
More details [here](https://discordapp.com/developers/docs/resources/channel#message-object-message-activity-structure).
"""
struct MessageActivity
    type::MessageActivityType
    party_id::Optional{String}
end
@boilerplate MessageActivity :constructors :docs :lower :merge :mock

"""
A Rich Presence [`Message`](@ref)'s application information.
More details [here](https://discordapp.com/developers/docs/resources/channel#message-object-message-application-structure).
"""
struct MessageApplication
    id::Snowflake
    cover_image::Optional{String}
    description::String
    icon::String
    name::String
end
@boilerplate MessageApplication :constructors :docs :lower :merge :mock

"""
A message sent to a [`DiscordChannel`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/channel#message-object).
"""
struct Message
    id::Snowflake
    channel_id::Snowflake
    # MessageUpdate only requires the ID and channel ID.
    guild_id::Optional{Snowflake}
    author::Optional{User}
    member::Optional{Member}
    content::Optional{String}
    timestamp::Optional{DateTime}
    edited_timestamp::OptionalNullable{DateTime}
    tts::Optional{Bool}
    mention_everyone::Optional{Bool}
    mentions::Optional{Vector{User}}
    mention_roles::Optional{Vector{Snowflake}}
    attachments::Optional{Vector{Attachment}}
    embeds::Optional{Vector{Embed}}
    reactions::Optional{Vector{Reaction}}
    nonce::OptionalNullable{Snowflake}
    pinned::Optional{Bool}
    webhook_id::Optional{Snowflake}
    type::Optional{MessageType}
    activity::Optional{MessageActivity}
    application::Optional{MessageApplication}
end
@boilerplate Message :constructors :docs :lower :merge :mock
