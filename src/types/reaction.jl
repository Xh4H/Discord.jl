"""
A reaction.
More details [here](https://discordapp.com/developers/docs/resources/channel#reaction-object).
"""
@from_dict mutable struct Reaction  # Mutable to update count and me.
    count::Int
    me::Bool
    emoji::Emoji
end
