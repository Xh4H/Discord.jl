struct MessageDelete <: AbstractEvent
    id::Snowflake
    channel_id::Snowflake
    guild_id::Union{Snowflake, Nothing}
end

function Base.convert(::Type{MessageDelete}, data::Dict)
    return MessageDelete(
        snowflake(data["id"]),
        snowflake(data["channel_id"]),
        snowflake(data["guild_id"]),
    )
end
