export Role

"""
A [`User`](@ref) role.
More details [here](https://discordapp.com/developers/docs/topics/permissions#role-object).
"""
struct Role
    id::Snowflake
    name::String
    color::Union{Int, Missing}  # These fields are missing in audit log entries.
    hoist::Union{Bool, Missing}
    position::Union{Int, Missing}
    permissions::Union{Int, Missing}
    managed::Union{Bool, Missing}
    mentionable::Union{Bool, Missing}
end
@boilerplate Role :constructors :docs :lower :merge
