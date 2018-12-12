export Emoji

"""
An emoji.
More details [here](https://discordapp.com/developers/docs/resources/emoji#emoji-object).
"""
struct Emoji
    id::Nullable{Snowflake}
    name::String
    roles::Optional{Vector{Snowflake}}
    user::Optional{User}
    require_colons::Optional{Bool}
    managed::Optional{Bool}
    animated::Optional{Bool}
end
@boilerplate Emoji :constructors :docs :lower :merge :mock
