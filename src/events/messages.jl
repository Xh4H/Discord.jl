export MessageCreate,
    MessageUpdate,
    MessageDelete,
    MessageDeleteBulk,
    MessageReactionAdd,
    MessageReactionRemove,
    MessageReactionRemoveAll

struct MessageCreate <: AbstractEvent
    message::Message
end

MessageCreate(d::Dict{String, Any}) = MessageCreate(Message(d))

JSON.lower(mc::MessageCreate) = JSON.lower(mc.message)

struct MessageUpdate <: AbstractEvent
    message::Message
end

MessageUpdate(d::Dict{String, Any}) = MessageUpdate(Message(d))

JSON.lower(mu::MessageUpdate) = JSON.lower(mu.message)

@from_dict struct MessageDelete <: AbstractEvent
    id::Snowflake
    channel_id::Snowflake
    guild_id::Union{Snowflake, Nothing}
end

@from_dict struct MessageDeleteBulk <: AbstractEvent
    ids::Vector{Snowflake}
    channel_id::Snowflake
    guild_id::Union{Snowflake, Nothing}
end

@from_dict struct MessageReactionAdd <: AbstractEvent
    user_id::Snowflake
    channel_id::Snowflake
    message_id::Snowflake
    guild_id::Union{Snowflake, Nothing}
    emoji::Emoji
end

@from_dict struct MessageReactionRemove <: AbstractEvent
    user_id::Snowflake
    channel_id::Snowflake
    message_id::Snowflake
    guild_id::Union{Snowflake, Nothing}
    emoji::Emoji
end

@from_dict struct MessageReactionRemoveAll <: AbstractEvent
    user_id::Snowflake
    channel_id::Snowflake
    message_id::Snowflake
    guild_id::Union{Snowflake, Nothing}
end
