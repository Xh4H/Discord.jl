export  PresenceUpdate, TypingStart

struct PresenceUpdate <: AbstractEvent
    presence::Presence
end

PresenceUpdate(d::Dict) = PresenceUpdate(Presence(d))

struct TypingStart <: AbstractEvent
    channel_id::Snowflake
    guild_id::Union{Snowflake, Nothing}
    user_id::Snowflake
    timestamp::DateTime
end

function TypingStart(d::Dict)
    return TypingStart(
        snowflake(d["channel_id"]),
        d["guild_id"] === nothing ? nothing : snowflake(d["guild_id"]),
        snowflake(d["user_id"]),
        unix2datetime(d["timestamp"]),
    )
end

struct UserUpdate <: AbstractEvent
    user::User
end

UserUpdate(d::Dict) = UserUpdate(User(d))
