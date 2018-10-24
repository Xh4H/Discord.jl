"""
An emoji.
More details [here](https://discordapp.com/developers/docs/resources/emoji#emoji-object).
"""
struct Emoji
    id::Union{Snowflake, Nothing}
    name::String
    roles::Union{Vector{Snowflake}, Missing}
    user::Union{User, Missing}
    require_colons::Union{Bool, Missing}
    managed::Union{Bool, Missing}
    animated::Union{Bool, Missing}
end
@boilerplate Emoji :dict :lower :merge
