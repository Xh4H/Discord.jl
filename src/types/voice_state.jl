"""
A [`User`](@ref)'s voice connection status.
More details [here](https://discordapp.com/developers/docs/resources/voice#voice-state-object).
"""
struct VoiceState
    guild_id::Union{Snowflake, Missing}
    channel_id::Union{Snowflake, Nothing}
    user_id::Snowflake
    member::Union{Member, Missing}
    session_id::String
    deaf::Bool
    mute::Bool
    self_deaf::Bool
    self_mute::Bool
    suppress::Bool
end
@boilerplate VoiceState :dict :docs :lower :merge
