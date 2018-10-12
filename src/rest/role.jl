export modify_role,
    delete_role

# TODO: Similar to in overwrite.jl, this might be more intuitive as f(c, guild, role).

"""
    modify_role(c::Client, guild::Union{Guild, Integer}, role::Union{Role, Integer}; params...) -> Response{Role}

Modify a given [`Role`](@ref) in the given [`DiscordChannel`](@ref).

# Keywords
- `name::AbstractString`: Name of the role.
- `permissions::Int`: Bitwise OR of the enabled/disabled permissions.
- `color::Int`: RGB color value.
- `hoist::Bool`: Whether the role should be displayed separately in the sidebar.
- `mentionable::Bool`: Whether the role should be mentionable.

More details [here](https://discordapp.com/developers/docs/resources/guild#modify-guild-role).
"""
function modify_role(c::Client, guild::Integer, role::Integer; params...)
    return Response{Role}(c, :PATCH, "/guilds/$guild/roles/$role"; body=params)
end

modify_role(c::Client, guild::Integer, role::Role; params...) = modify_role(c, guild, role.id; params...)
modify_role(c::Client, guild::Guild, role::Integer; params...) = modify_role(c, guild.id, role; params...)
modify_role(c::Client, guild::Guild, role::Role; params...) = modify_role(c, guild.id, role.id; params...)


"""
    delete_role(c::Client, guild::Union{Guild, Integer}, role::Union{Role, Integer}) -> Response{Nothing}

Modify a given [`Role`](@ref) in the given [`DiscordChannel`](@ref).
"""
function delete_role(c::Client, guild::Integer, role::Integer)
    return Response{Nothing}(c, :DELETE, "/guilds/$guild/roles/$role")
end

delete_role(c::Client, guild::Integer, role::Role) = delete_role(c, guild, role.id)
delete_role(c::Client, guild::Guild, role::Integer) = delete_role(c, guild.id, role)
delete_role(c::Client, guild::Guild, role::Role) = delete_role(c, guild.id, role.id)
