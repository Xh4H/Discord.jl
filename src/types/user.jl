export User

"""
A Discord user.
More details [here](https://discordapp.com/developers/docs/resources/user#user-object).
"""
struct User
    id::Snowflake
    # The User inside of a Presence only needs its ID set.
    username::Union{String, Missing}
    discriminator::Union{String, Missing}
    avatar::Union{String, Nothing, Missing}
    bot::Union{Bool, Missing}
    mfa_enabled::Union{Bool, Missing}
    locale::Union{String, Missing}
    verified::Union{Bool, Missing}
    email::Union{String, Nothing, Missing}  # Not supposed to be nullable.
    # TODO: There's a member field here in one case.
end
@boilerplate User :constructors :docs :lower :merge :mock
