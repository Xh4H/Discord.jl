"""
An emoji.
More details [here](https://discordapp.com/developers/docs/resources/emoji#emoji-object).
"""
@from_dict struct Emoji
    id::Union{Snowflake, Missing}
    name::String
    roles::Union{Vector{Snowflake}, Nothing}
    user::Union{User, Nothing}
    require_colons::Union{Bool, Nothing}
    managed::Union{Bool, Nothing}
    animated::Union{Bool, Nothing}
end
