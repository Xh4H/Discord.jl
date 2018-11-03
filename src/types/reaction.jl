export Reaction

"""
A [`Message`](@ref) reaction.
More details [here](https://discordapp.com/developers/docs/resources/channel#reaction-object).
"""
struct Reaction
    count::Int
    me::Bool
    emoji::Emoji
end
@boilerplate Reaction :dict :docs :lower :merge
