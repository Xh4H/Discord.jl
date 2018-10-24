"""
A Discord user.
More details [here](https://discordapp.com/developers/docs/resources/user#user-object).
"""
struct User
    id::Snowflake
    # TODO: There's one case where everything but id is missing.
    # Find it in the docs and refer to it here.
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
@boilerplate User :dict :lower :merge
