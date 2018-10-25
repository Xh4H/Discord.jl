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

"""
Sent when a [`Message`](@ref) is updated.
"""
struct MessageUpdate <: AbstractEvent
    message::Message
end
MessageUpdate(d::Dict{String, Any}) = MessageUpdate(Message(d))

"""
Sent when a [`Message`](@ref) is deleted.
"""
struct MessageDelete <: AbstractEvent
    id::Snowflake
    channel_id::Snowflake
    guild_id::Union{Snowflake, Missing}
end
@boilerplate MessageDelete :dict

"""
Sent when multiple [`Message`](@ref)s are deleted in bulk.
"""
struct MessageDeleteBulk <: AbstractEvent
    ids::Vector{Snowflake}
    channel_id::Snowflake
    guild_id::Union{Snowflake, Missing}
end
@boilerplate MessageDeleteBulk :dict

"""
Sent when a [`Reaction`](@ref) is added to a [`Message`](@ref).
"""
struct MessageReactionAdd <: AbstractEvent
    user_id::Snowflake
    channel_id::Snowflake
    message_id::Snowflake
    guild_id::Union{Snowflake, Missing}
    emoji::Emoji
end
@boilerplate MessageReactionAdd :dict

"""
Sent when a [`Reaction`](@ref) is removed from a [`Message`](@ref).
"""
struct MessageReactionRemove <: AbstractEvent
    user_id::Snowflake
    channel_id::Snowflake
    message_id::Snowflake
    guild_id::Union{Snowflake, Missing}
    emoji::Emoji
end
@boilerplate MessageReactionRemove :dict

"""
Sent when all [`Reaction`](@ref)s are removed from a [`Message`](@ref).
"""
struct MessageReactionRemoveAll <: AbstractEvent
    channel_id::Snowflake
    message_id::Snowflake
    guild_id::Union{Snowflake, Missing}
end
@boilerplate MessageReactionRemoveAll :dict
