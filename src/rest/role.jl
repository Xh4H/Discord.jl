export edit_role,
    delete_role

"""
    edit_role(
        c::Client,
        role::Union{Role, Integer},
        guild::Union{AbstractGuild, Integer};
        params...
    ) -> Response{Role}

Modify a [`Role`](@ref) in a [`DiscordChannel`](@ref).

# Keywords
- `name::AbstractString`: Name of the role.
- `permissions::Int`: Bitwise OR of the enabled/disabled permissions.
- `color::Int`: RGB color value.
- `hoist::Bool`: Whether the role should be displayed separately in the sidebar.
- `mentionable::Bool`: Whether the role should be mentionable.

More details [here](https://discordapp.com/developers/docs/resources/guild#modify-guild-role).
"""
function edit_role(c::Client, role::Int, guild::Int; params...)
    return Response{Role}(c, :PATCH, "/guilds/$guild/roles/$role"; body=params)
end

function edit_role(c::Client, r::Role, g::AbstractGuild; params...)
    return edit_role(c, r.id, g.id; params...)
end

function edit_role(c::Client, r::Role, guild::Int; params...)
    return edit_role(c, r.id, guild; params...)
end

function edit_role(c::Client, role::Int, g::AbstractGuild; params...)
    return edit_role(c, r, g.id; params...)
end

"""
    delete_role(
        c::Client,
        role::Union{Role, Integer},
        guild::Union{AbstractGuild, Integer}
    ) -> Response

Modify a [`Role`](@ref) in a [`DiscordChannel`](@ref).
"""
function delete_role(c::Client, guild::Int, role::Int)
    return Response(c, :DELETE, "/guilds/$guild/roles/$role")
end

delete_role(c::Client, guild::Int, r::Role) = delete_role(c, guild, r.id)

delete_role(c::Client, guild::AbstractGuild, role::Int) = delete_role(c, g.id, role)

delete_role(c::Client, guild::AbstractGuild, role::Role) = delete_role(c, g.id, r.id)
