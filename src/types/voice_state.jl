"""
A voice state.
More details [here](https://discordapp.com/developers/docs/resources/voice#voice-state-object).
"""
@from_dict struct VoiceState
    guild_id::Union{Snowflake, Nothing}
    channel_id::Union{Snowflake, Missing}
    user_id::Snowflake
    member::Union{GuildMember, Nothing}
    session_id::String
    deaf::Bool
    mute::Bool
    self_deaf::Bool
    self_mute::Bool
    suppress::Bool
end
