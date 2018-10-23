"""
<<<<<<< HEAD
A [`User`](@ref) Connection.
=======
A [`User`](@ref) connection to an external service (Twitch, YouTube, etc.).
>>>>>>> master
More details [here](https://discordapp.com/developers/docs/resources/user#connection-object).
"""
@from_dict struct Connection
    id::String
    name::String
    type::String
    revoked::Bool
    integrations::Vector{Integration}
end
