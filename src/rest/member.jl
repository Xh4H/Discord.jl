export edit_member,
    ban_member,
    kick_member,
    add_role,
    remove_role,
"""
    edit_member(
        c::Client,
        guild::Union{AbstractGuild, Integereger},
        user::Union{User, Integereger};
        params...,
    ) -> Response{Member}

Modify a [`Member`](@ref).

# Keywords
- `nick::AbstractString`: Value to set the member's nickname to.
- `roles::Vector`: List of role ids the member is assigned.
- `mute::Bool`: Whether the member should be muted.
- `deaf::Bool`: Whether the member should be deafened.
- `channel_id::Integer`: ID of a voice channel to move the member to.

More details [here](https://discordapp.com/developers/docs/resources/guild#modify-guild-member).
"""
function edit_member(c::Client, guild::Integer, user::Integer; params...)
    return Response{Webhook}(c, :PATCH, "/guilds/$guild/members/$user"; body=params)
end

function edit_member(c::Client, g::AbstractGuild, u::User; params...)
    return edit_member(c, g.id, u.id; params...)
end

function edit_member(c::Client, guild::Integer, u::User; params...)
    return edit_member(c, guild, user.id; params...)
end

function edit_member(c::Client, g::AbstractGuild, user::Integer; params...)
    return edit_member(c, guild.id, user; params...)
end

"""
    ban_member(
        c::Client,
        guild::Union{Guild, Integereger},
        user::Union{User, Integereger};
        params...,
    ) -> Response

Ban a [`Member`](@ref).

# Keywords
- `delete_message_days::Integer`: Number of days to delete the messages for (0-7).
- `reason::AbstractString`: Reason for the ban.
"""
function ban_member(c::Client, guild::Integer, user::Integer; params...)
    # TODO: How to pass delete_message_days as delete-message-days?
    return Response(c, :PUT, "/guilds/$guild/bans/$user"; params...)
end

function ban_member(c::Client, g::AbstractGuild, u::User; params...)
    return ban_member(c, g.id, u.id; params...)
end

function ban_member(c::Client, guild::Integer, u::User; params...)
    return ban_member(c, guild, u.id; params...)
end

function ban_member(c::Client, g::AbstractGuild, user::Integer; params...)
    return ban_member(c, g.id, user; params...)
end

"""
    kick_member(
        c::Client,
        guild::Union{AbstractGuild, Integereger},
        user::Union{User, Integereger},
    ) -> Response

Kick a [`Member`](@ref).
"""
function kick_member(c::Client, guild::Integer, user::Integer)
    return Response(c, :DELETE, "/guilds/$guild/members/$user")
end

kick_member(c::Client, g::AbstractGuild, u::User) = kick_member(c, g.id, u.id)

kick_member(c::Client, guild::Integer, u::User) = kick_member(c, guild, u.id)

kick_member(c::Client, g::AbstractGuild, user::Integer) = kick_member(c, g.id, user)

"""
    add_role(
        c::Client,
        guild::Union{AbstractGuild, Integereger},
        user::Union{User, Integereger},
        role::Union{Role, Integereger},
    ) -> Response

Add a [`Role`](@ref) to a [`Member`](@ref).
"""
function add_role(c::Client, guild::Integer, user::Integer, role::Integer)
    return Response(c, :PUT, "/guilds/$guild/members/$user/roles/$role")
end

function add_role(c::Client, g::AbstractGuild, u::User, r::Role)
    return add_role(c, g.id, u.id, r.id)
end

function add_role(c::Client, g::AbstractGuild, u::User, role::Integer)
    return add_role(c, g.id, u.id, role)
end

function add_role(c::Client, g::AbstractGuild, user::Integer, r::Role)
    return add_role(c, g.id, user, r.id)
end

function add_role(c::Client, g::AbstractGuild, user::Integer, role::Integer)
    return add_role(c, g.id, user, role)
end

function add_role(c::Client, guild::Integer, u::User, r::Role)
    return add_role(c, guild, u.id, r.id)
end

function add_role(c::Client, guild::Integer, u::User, role::Integer)
    return add_role(c, guild, u.id, role)
end

function add_role(c::Client, guild::Integer, user::Integer, role::Role)
    return add_role(c, guild, user, r.id)
end

"""
    remove_role(
        c::Client,
        guild::Union{AbstractGuild, Integereger},
        user::Union{User, Integereger},
        role::Union{Role, Integereger},
    ) -> Response

Remove a [`Role`](@ref) from a [`Member`](@ref).
"""
function remove_role(c::Client, guild::Integer, user::Integer, role::Integer)
    return Response(c, :DELETE, "/guilds/$guild/members/$user/roles/$role")
end

function remove_role(c::Client, g::AbstractGuild, u::User, r::Role)
    return remove_role(c, g.id, u.id, r.id)
end

function remove_role(c::Client, g::AbstractGuild, u::User, role::Integer)
    return remove_role(c, g.id, user.id, role)
end

function remove_role(c::Client, g::AbstractGuild, user::Integer, r::Role)
    return remove_role(c, g.id, user, r.id)
end

function remove_role(c::Client, g::AbstractGuild, user::Integer, role::Integer)
    return remove_role(c, g.id, user, role)
end

function remove_role(c::Client, guild::Integer, u::User, r::Role)
    return remove_role(c, guild, u.id, r.id)
end

function remove_role(c::Client, guild::Integer, u::User, role::Integer)
    return remove_role(c, guild, u.id, role)
end

function remove_role(c::Client, guild::Integer, user::Integer, r::Role)
    return remove_role(c, guild, user, r.id)
end
