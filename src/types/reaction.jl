"""
A reaction.
More details [here](https://discordapp.com/developers/docs/resources/channel#reaction-object).
"""
@from_dict struct Reaction
    count::Int
    me::Bool
    emoji::Emoji
end
