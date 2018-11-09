export VoiceStateUpdate,
    VoiceServerUpdate

"""
Sent when a [`User`](@ref) updates their [`VoiceState`](@ref).
"""
struct VoiceStateUpdate <: AbstractEvent
    state::VoiceState
end
@boilerplate VoiceStateUpdate :docs
VoiceStateUpdate(d::Dict{String, Any}) = VoiceStateUpdate(VoiceState(d))

"""
Sent when a [`Guild`](@ref)'s voice server is updated.
"""
struct VoiceServerUpdate <: AbstractEvent
    token::String
    guild_id::Snowflake
    endpoint::String
end
@boilerplate VoiceServerUpdate :dict :docs
