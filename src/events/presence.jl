export  PresenceUpdate, TypingStart

struct PresenceUpdate <: AbstractEvent
    presence::Presence
end

PresenceUpdate(d::Dict{String, Any}) = PresenceUpdate(Presence(d))

struct TypingStart <: AbstractEvent
    channel_id::Snowflake
    guild_id::Union{Snowflake, Nothing}
    user_id::Snowflake
    timestamp::DateTime
    extra_fields::Dict{String, Any}
end

function TypingStart(d::Dict{String, Any})
    return TypingStart(
        snowflake(d["channel_id"]),
        d["guild_id"] === nothing ? nothing : snowflake(d["guild_id"]),
        snowflake(d["user_id"]),
        unix2datetime(d["timestamp"]),
        extra_fields(TypingStart, d),
    )
end

struct UserUpdate <: AbstractEvent
    user::User
end

UserUpdate(d::Dict{String, Any}) = UserUpdate(User(d))
