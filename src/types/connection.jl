"""
A [`User`](@ref) connection to an external service (Twitch, YouTube, etc.).
More details [here](https://discordapp.com/developers/docs/resources/user#connection-object).
"""
struct Connection
    id::String
    name::String
    type::String
    revoked::Bool
    integrations::Vector{Integration}
end
@boilerplate Connection :constructors :docs :lower :merge :mock
