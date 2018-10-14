export VoiceStateUpdate,
    VoiceServerUpdate

struct VoiceStateUpdate <: AbstractEvent
    state::VoiceState
end

VoiceStateUpdate(d::Dict{String, Any}) = VoiceStateUpdate(VoiceState(d))

JSON.lower(vsu::VoiceStateUpdate) = JSON.lower(vsu.state)

@from_dict struct VoiceServerUpdate <: AbstractEvent
    token::String
    guild_id::Snowflake
    endpoint::String
end
