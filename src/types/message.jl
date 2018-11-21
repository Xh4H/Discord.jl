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
    party_id::Union{String, Missing}
end
@boilerplate MessageActivity :constructors :docs :lower :merge :mock

"""
A Rich Presence [`Message`](@ref)'s application information.
More details [here](https://discordapp.com/developers/docs/resources/channel#message-object-message-application-structure).
"""
struct MessageApplication
    id::Snowflake
    cover_image::String
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
    guild_id::Union{Snowflake, Missing}
    author::Union{User, Missing}
    member::Union{Member, Missing}
    content::Union{String, Missing}
    timestamp::Union{DateTime, Missing}
    edited_timestamp::Union{DateTime, Nothing, Missing}
    tts::Union{Bool, Missing}
    mention_everyone::Union{Bool, Missing}
    mentions::Union{Vector{User}, Missing}
    mention_roles::Union{Vector{Snowflake}, Missing}
    attachments::Union{Vector{Attachment}, Missing}
    embeds::Union{Vector{Embed}, Missing}
    reactions::Union{Vector{Reaction}, Missing}
    nonce::Union{Snowflake, Nothing, Missing}
    pinned::Union{Bool, Missing}
    webhook_id::Union{Snowflake, Missing}
    type::Union{MessageType, Missing}
    activity::Union{MessageActivity, Missing}
    application::Union{MessageApplication, Missing}
end
@boilerplate Message :constructors :docs :lower :merge :mock
