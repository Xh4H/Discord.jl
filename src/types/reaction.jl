"""
A [`Message`](@ref) reaction.
More details [here](https://discordapp.com/developers/docs/resources/channel#reaction-object).
"""
mutable struct Reaction  # Mutable to update count and me.
    count::Int
    me::Bool
    emoji::Emoji
end
@boilerplate Reaction :dict :lower :merge
