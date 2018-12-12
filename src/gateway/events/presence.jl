export PresenceUpdate,
    TypingStart,
    UserUpdate

"""
Sent when a [`User`](@ref)'s [`Presence`](@ref) is updated.
"""
struct PresenceUpdate <: AbstractEvent
    presence::Presence
end
@boilerplate PresenceUpdate :docs :mock
PresenceUpdate(; kwargs...) = PresenceUpdate(Presence(; kwargs...))
PresenceUpdate(d::Dict{Symbol, Any}) = PresenceUpdate(; d...)

"""
Sent when a [`User`](@ref) begins typing.
"""
struct TypingStart <: AbstractEvent
    channel_id::Snowflake
    guild_id::Optional{Snowflake}
    user_id::Snowflake
    timestamp::DateTime
end
@boilerplate TypingStart :constructors :docs :mock

"""
Sent when a [`User`](@ref)'s details are updated.
"""
struct UserUpdate <: AbstractEvent
    user::User
end
@boilerplate UserUpdate :docs :mock
UserUpdate(; kwargs...) = UserUpdate(User(; kwargs...))
UserUpdate(d::Dict{Symbol, Any}) = UserUpdate(; d...)
