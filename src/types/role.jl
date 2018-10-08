"""
A role.
More details [here](https://discordapp.com/developers/docs/topics/permissions#role-object).
"""
@from_dict struct Role
    id::Snowflake
    name::String
    color::Int
    hoise::Bool
    position::Int
    permissions::Int
    managed::Bool
    mentionable::Bool
end
