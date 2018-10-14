export  PresenceUpdate, TypingStart

struct PresenceUpdate <: AbstractEvent
    presence::Presence
end

PresenceUpdate(d::Dict{String, Any}) = PresenceUpdate(Presence(d))

JSON.lower(pu::PresenceUpdate) = JSON.lower(pu.presence)

struct TypingStart <: AbstractEvent
    channel_id::Snowflake
    guild_id::Union{Snowflake, Missing}
    user_id::Snowflake
    timestamp::DateTime
    extra_fields::Dict{String, Any}
end

function TypingStart(d::Dict{String, Any})
    return TypingStart(
        snowflake(d["channel_id"]),
        haskey(d, "guild_id") ? snowflake(d["guild_id"]) : missing,
        snowflake(d["user_id"]),
        unix2datetime(d["timestamp"]),
        extra_fields(TypingStart, d),
    )
end

function JSON.lower(ts::TypingStart)
    d = Dict{Any, Any}(
        "channel_id" => JSON.lower(ts.channel_id),
        "user_id" => JSON.lower(ts.user_id),
        "timestamp" => datetime2unix(ts.timestamp),
    )
    if !ismissing(ts.guild_id)
        d["guild_id"] = JSON.lower(ts.guild_id)
    end
    return d
end

struct UserUpdate <: AbstractEvent
    user::User
end

UserUpdate(d::Dict{String, Any}) = UserUpdate(User(d))

JSON.lower(uu::UserUpdate) = JSON.lower(uu.user)
