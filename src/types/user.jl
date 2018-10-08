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
    # TODO: User can apparently also have a partial member field
    # in a Message's mentions field, but GuildMember depends on User.
    # member::Union{GuildMember, Missing}
end
