export User

"""
A Discord user. 
See [here](https://discordapp.com/developers/docs/resources/user#user-object) for details.
"""
@from_dict struct User
    id::Snowflake
    username::String
    discriminator::String
    avatar::Union{String, Missing}
    bot::Union{Bool, Nothing}
    mfa_enabled::Union{Bool, Nothing}
    locale::Union{String, Nothing}
    verified::Union{Bool, Nothing}
    email::Union{String, Nothing}
end
