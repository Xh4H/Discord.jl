export VoiceStateUpdate, VoiceServerUpdate

struct VoiceStateUpdate <: AbstractEvent
    state::VoiceState
end

VoiceStateUpdate(d::Dict) = VoiceStateUpdate(VoiceState(d))

@from_dict struct VoiceServerUpdate <: AbstractEvent
    token::String
    guild_id::Snowflake
    endpoint::String
end
