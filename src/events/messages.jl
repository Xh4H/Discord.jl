export MessageCreate,
    MessageUpdate,
    MessageDelete,
    MessageDeleteBulk,
    MessageReactionAdd,
    MessageReactionRemove,
    MessageReactionRemoveAll

"""
Sent when a [`Message`](@ref) is sent.
"""
struct MessageCreate <: AbstractEvent
    message::Message
end

MessageCreate(d::Dict{String, Any}) = MessageCreate(Message(d))

JSON.lower(mc::MessageCreate) = JSON.lower(mc.message)

struct MessageUpdate <: AbstractEvent
    message::Message
end

"""
Sent when a [`Message`](@ref) is updated.
"""
MessageUpdate(d::Dict{String, Any}) = MessageUpdate(Message(d))

JSON.lower(mu::MessageUpdate) = JSON.lower(mu.message)

"""
Sent when a [`Message`](@ref) is deleted.
"""
@from_dict struct MessageDelete <: AbstractEvent
    id::Snowflake
    channel_id::Snowflake
    guild_id::Union{Snowflake, Missing}
end

"""
Sent when multiple [`Message`](@ref)s are deleted in bulk.
"""
@from_dict struct MessageDeleteBulk <: AbstractEvent
    ids::Vector{Snowflake}
    channel_id::Snowflake
    guild_id::Union{Snowflake, Missing}
end

"""
Sent when a [`Reaction`](@ref) is added to a [`Message`](@ref).
"""
@from_dict struct MessageReactionAdd <: AbstractEvent
    user_id::Snowflake
    channel_id::Snowflake
    message_id::Snowflake
    guild_id::Union{Snowflake, Missing}
    emoji::Emoji
end

"""
Sent when a [`Reaction`](@ref) is removed from a [`Message`](@ref).
"""
@from_dict struct MessageReactionRemove <: AbstractEvent
    user_id::Snowflake
    channel_id::Snowflake
    message_id::Snowflake
    guild_id::Union{Snowflake, Missing}
    emoji::Emoji
end

"""
Sent when all [`Reaction`](@ref)s are removed from a [`Message`](@ref).
"""
@from_dict struct MessageReactionRemoveAll <: AbstractEvent
    user_id::Snowflake
    channel_id::Snowflake
    message_id::Snowflake
    guild_id::Union{Snowflake, Missing}
end
