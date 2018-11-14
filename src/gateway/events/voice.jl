export VoiceStateUpdate,
    VoiceServerUpdate

"""
Sent when a [`User`](@ref) updates their [`VoiceState`](@ref).
"""
struct VoiceStateUpdate <: AbstractEvent
    state::VoiceState
end
@boilerplate VoiceStateUpdate :docs :mock
VoiceStateUpdate(; kwargs...) = VoiceStateUpdate(VoiceState(; kwargs...))
VoiceStateUpdate(d::Dict{Symbol, Any}) = VoiceStateUpdate(; d...)

"""
Sent when a [`Guild`](@ref)'s voice server is updated.
"""
struct VoiceServerUpdate <: AbstractEvent
    token::String
    guild_id::Snowflake
    endpoint::String
end
@boilerplate VoiceServerUpdate :constructors :docs :mock
