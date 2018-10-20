export VoiceStateUpdate,
    VoiceServerUpdate

"""
Sent when a [`User`](@ref) updates their [`VoiceState`](@ref).
"""
struct VoiceStateUpdate <: AbstractEvent
    state::VoiceState
end

VoiceStateUpdate(d::Dict{String, Any}) = VoiceStateUpdate(VoiceState(d))

JSON.lower(vsu::VoiceStateUpdate) = JSON.lower(vsu.state)

"""
Sent when a [`Guild`](@ref)'s voice server is updated.
"""
@from_dict struct VoiceServerUpdate <: AbstractEvent
    token::String
    guild_id::Snowflake
    endpoint::String
end
