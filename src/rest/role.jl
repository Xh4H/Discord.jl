export modify_role,
    delete_role

# TODO: Similar to in overwrite.jl, this might be more intuitive as f(c, guild, role).

"""
    modify_role(c::Client, role::Snowflake, guild::Snowflake; params...) -> Response{Role}

Modify a given [`Role`](@ref) in the given [`DiscordChannel`](@ref).

# Keywords
- `name::AbstractString`: Name of the role.
- `permissions::Int`: Bitwise of the enabled/disabled permissions.
- `color::Int`: RGB color value.
- `hoist::Bool`: Whether the role should be displayed separately in the sidebar.
- `mentionable::Bool`: Whether the role should be mentionable.

More details [here](https://discordapp.com/developers/docs/resources/guild#modify-guild-role).
"""
function modify_role(c::Client, role::Snowflake, guild::Snowflake; params...)
    return Response{Role}(c, :PATCH, "/guilds/$guild/roles/$role"; body=params)
end

"""
    delete_role(c::Client, role::Snowflake, guild::Snowflake) -> Response{Nothing}

Modify a given [`Role`](@ref) in the given [`DiscordChannel`](@ref).
"""
function delete_role(c::Client, role::Snowflake, guild::Snowflake)
    return Response{Nothing}(c, :DELETE, "/guilds/$guild/roles/$role")
end
