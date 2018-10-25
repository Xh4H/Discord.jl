"""
A region for a [`Guild`](@ref)'s voice server.
More details [here](https://discordapp.com/developers/docs/resources/voice#voice-region-object).
"""
struct VoiceRegion
    id::String
    name::String
    vip::Bool
    optimal::Bool
    deprecated::Bool
    custom::Bool
end
@boilerplate VoiceRegion :dict :docs :lower :merge
