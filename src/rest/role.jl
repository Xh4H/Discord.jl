export modify_role,
        delete_role

"""
    modify_role(c::Client, role::Snowflake, guild::Snowflake; params...) -> Response{Role}

Modify a given [`Role`](@ref) in the given [`DiscordChannel`](@ref) with the given parameters.

# Keywords
- `name::AbstractString`: name of the role.
- `permissions::Int`: bitwise of the enabled/disabled permissions.
- `color::Int`: RGB color value.
- `hoist::Bool`: whether the role should be displayed separately in the sidebar.
- `mentionable::Bool`: whether the role should be mentionable.

More details [here](https://discordapp.com/developers/docs/resources/guild#modify-guild-role).
"""
function modify_role(c::Client, role::Snowflake, guild::Snowflake; params...)
    return Response{Role}(c, :PATCH, "/guilds/$guild/roles/$role"; params...)
end

"""
    delete_role(c::Client, role::Snowflake, guild::Snowflake) -> Response{Nothing}

Modify a given [`Role`](@ref) in the given [`DiscordChannel`](@ref) with the given parameters.
"""
function delete_role(c::Client, role::Snowflake, guild::Snowflake)
    return Response{Nothing}(c, :DELETE, "/guilds/$guild/roles/$role")
end
