export PresenceUpdate,
    TypingStart,
    UserUpdate

"""
Sent when a [`User`](@ref)'s [`Presence`](@ref) is updated.
"""
struct PresenceUpdate <: AbstractEvent
    presence::Presence
end
PresenceUpdate(d::Dict{String, Any}) = PresenceUpdate(Presence(d))

"""
Sent when a [`User`](@ref) begins typing.
"""
struct TypingStart <: AbstractEvent
    channel_id::Snowflake
    guild_id::Union{Snowflake, Missing}
    user_id::Snowflake
    timestamp::DateTime
end
@boilerplate TypingStart :dict

"""
Sent when a [`User`](@ref)'s details are updated.
"""
struct UserUpdate <: AbstractEvent
    user::User
end
UserUpdate(d::Dict{String, Any}) = UserUpdate(User(d))
