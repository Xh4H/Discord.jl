"""
A [`User`](@ref)'s voice connection status.
More details [here](https://discordapp.com/developers/docs/resources/voice#voice-state-object).
"""
struct VoiceState
    guild_id::Optional{Snowflake}
    channel_id::Nullable{Snowflake}
    user_id::Snowflake
    member::Optional{Member}
    session_id::String
    deaf::Bool
    mute::Bool
    self_deaf::Bool
    self_mute::Bool
    suppress::Bool
end
@boilerplate VoiceState :constructors :docs :lower :merge :mock
