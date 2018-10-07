export MessageDelete

struct MessageDelete <: AbstractEvent
    id::Snowflake
    channel_id::Snowflake
    guild_id::Union{Snowflake, Nothing}

    function MessageDelete(data::Dict)
        return new(
            snowflake(data["id"]),
            snowflake(data["channel_id"]),
            snowflake(data["guild_id"]),
        )
    end
end
