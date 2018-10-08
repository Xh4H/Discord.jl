export User

"""
A Discord user. 
More details [here](https://discordapp.com/developers/docs/resources/user#user-object).
"""
@from_dict struct User
    id::Snowflake
    username::Union{String, Missing}
    discriminator::Union{String, Missing}
    avatar::Union{String, Missing}
    bot::Union{Bool, Nothing, Missing}
    mfa_enabled::Union{Bool, Nothing, Missing}
    locale::Union{String, Nothing, Missing}
    verified::Union{Bool, Nothing, Missing}
    email::Union{String, Nothing, Missing}
end
