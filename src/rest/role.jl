export modify_role,
    delete_role

# TODO: Similar to in overwrite.jl, this might be more intuitive as f(c, guild, role).

"""
    modify_role(c::Client, role::Union{Role, Integer}, guild::Union{Guild, Integer}; params...) -> Response{Role}

Modify a given [`Role`](@ref) in the given [`DiscordChannel`](@ref).

# Keywords
- `name::AbstractString`: Name of the role.
- `permissions::Int`: Bitwise OR of the enabled/disabled permissions.
- `color::Int`: RGB color value.
- `hoist::Bool`: Whether the role should be displayed separately in the sidebar.
- `mentionable::Bool`: Whether the role should be mentionable.

More details [here](https://discordapp.com/developers/docs/resources/guild#modify-guild-role).
"""
function modify_role(c::Client, role::Integer, guild::Integer; params...)
    return Response{Role}(c, :PATCH, "/guilds/$guild/roles/$role"; body=params)
end

modify_role(c::Client, role::Role, guild::Integer; params...) = modify_role(c, role.id, guild; params...)
modify_role(c::Client, role::Integer, guild::Guild; params...) = modify_role(c, role, guild.id; params...)
modify_role(c::Client, role::Role, guild::Guild; params...) = modify_role(c, role.id, guild.id; params...)


"""
    delete_role(c::Client, role::Union{Role, Integer}, guild::Union{Guild, Integer}) -> Response{Nothing}

Modify a given [`Role`](@ref) in the given [`DiscordChannel`](@ref).
"""
function delete_role(c::Client, role::Integer, guild::Integer)
    return Response{Nothing}(c, :DELETE, "/guilds/$guild/roles/$role")
end

delete_role(c::Client, role::Role, guild::Integer) = delete_role(c, role.id, guild)
delete_role(c::Client, role::Integer, guild::Guild) = delete_role(c, role, guild.id)
delete_role(c::Client, role::Role, guild::Guild) = delete_role(c, role.id, guild.id)
