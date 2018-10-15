"""
A [`User`](@ref) Connection.
More details [here](https://discordapp.com/developers/docs/resources/user#connection-object).
"""
@from_dict struct Connection
    id::String
    name::String
    type::String
    revoked::Bool
    integrations::Vector{Integration}
end
