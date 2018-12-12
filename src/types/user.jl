export User

"""
A Discord user.
More details [here](https://discordapp.com/developers/docs/resources/user#user-object).
"""
struct User
    id::Snowflake
    # The User inside of a Presence only needs its ID set.
    username::Optional{String}
    discriminator::Optional{String}
    avatar::Union{String, Nothing, Missing}
    bot::Optional{Bool}
    mfa_enabled::Optional{Bool}
    locale::Optional{String}
    verified::Optional{Bool}
    email::Union{String, Nothing, Missing}  # Not supposed to be nullable.
end
@boilerplate User :constructors :docs :lower :merge :mock
