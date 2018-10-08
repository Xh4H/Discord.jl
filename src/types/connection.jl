@from_dict struct Connection
    id::String
    name::String
    type::String
    revoked::Bool
    integrations::Vector{Integration}
end
