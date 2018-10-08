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
@enum MessageActivityType MAT_JOIN MAT_SPECTATE MAT_LISTEN MAT_JOIN_REQUEST

@from_dict struct MessageActivity
    type::MessageActivityType
    party_id::Union{String, Missing}
end

@from_dict struct MessageApplication
    id::Snowflake
    cover_image::String
    description::String
    icon::String
    name::String
end

"""
A message.
More details [here](https://discordapp.com/developers/docs/resources/channel#message-object).
"""
@from_dict struct Message
    # TODO: Most of these should probably be optional.
    # https://discordapp.com/developers/docs/topics/gateway#message-update
    id::Snowflake
    channel_id::Snowflake
    guild_id::Union{Snowflake, Missing}
    author::User  # TODO: Deal with the note about non-standard user structure.
    member::Union{GuildMember, Missing}
    content::String
    timestamp::DateTime
    edited_timestamp::Union{DateTime, Nothing}
    tts::Bool
    mention_everyone::Bool
    mentions::Vector{User}
    mention_roles::Vector{Snowflake}
    attachments::Vector{Attachment}
    embeds::Vector{Embed}
    reactions::Union{Vector{Reaction}, Missing}
    nonce::Union{Snowflake, Nothing, Missing}
    pinned::Bool
    webhook_id::Union{Snowflake, Missing}
    type::MessageType
    activity::Union{MessageActivity, Missing}
    application::Union{MessageApplication, Missing}
end
