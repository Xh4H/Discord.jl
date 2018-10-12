export get_member

"""
    get_member(c::Client, guild::Union{Guild, Integer}, user::Union{User, Integer}) -> Response{Member}

Get a [`Member`](@ref) in the given guild.
"""
function get_member(c::Client, guild::Integer, user::Integer)
    return Response{Member}(c, :GET, "/guilds/$guild/members/$user")
end

get_member(c::Client, guild::Guild, user::User) = get_member(c, guild.id, user.id)
get_member(c::Client, guild::Integer, user::User) = get_member(c, guild, user.id)
get_member(c::Client, guild::Guild, user::Integer) = get_member(c, guild.id, user)

"""
    modify_member(c::Client, guild::Union{Guild, Integer}, user::Union{User, Integer}; params...) -> Response{Member}

Modify a [`Member`](@ref) in the given guild.

# Keywords
- `nick::AbstractString`: Value to set the member's nickname to.
- `roles::Array`: List of role ids the member is assigned.
- `mute::Bool`: Whether the member should be muted.
- `deaf::Bool`: Whether the member should be deafened.
- `channel_id::Integer`: ID of a voice channel to move the member to.

More details [here](https://discordapp.com/developers/docs/resources/guild#modify-guild-member).
"""
function modify_member(c::Client, guild::Integer, user::Integer; params...)
    return Response{Webhook}(c, :PATCH, "/guilds/$guild/members/$user"; body=params)
end

modify_member(c::Client, guild::Guild, user::User; params...) = modify_member(c, guild.id, user.id; params...)
modify_member(c::Client, guild::Integer, user::User; params...) = modify_member(c, guild, user.id; params...)
modify_member(c::Client, guild::Guild, user::Integer; params...) = modify_member(c, guild.id, user; params...)

"""
    ban_member(c::Client, guild::Union{Guild, Integer}, user::Union{User, Integer}; params...) -> Response{Nothing}

Ban a [`Member`](@ref) from the given guild.

# Query
- `delete-message-days::Integer`: Number of days to delete the messages for (0-7).
- `reason::AbstractString`: Reason for the ban.
"""
function ban_member(c::Client, guild::Integer, user::Integer; params...)
    return Response{Nothing}(c, :PUT, "/guilds/$guild/bans/$user"; params...)
end

ban_member(c::Client, guild::Guild, user::User; params...) = ban_member(c, guild.id, user.id; params...)
ban_member(c::Client, guild::Integer, user::User; params...) = ban_member(c, guild, user.id; params...)
ban_member(c::Client, guild::Guild, user::Integer; params...) = ban_member(c, guild.id, user; params...)

"""
    kick_member(c::Client, guild::Union{Guild, Integer}, user::Union{User, Integer}) -> Response{Nothing}

Kick a [`Member`](@ref) from the given guild.
"""
function kick_member(c::Client, guild::Integer, user::Integer)
    return Response{Nothing}(c, :DELETE, "/guilds/$guild/members/$user")
end

kick_member(c::Client, guild::Guild, user::User) = kick_member(c, guild.id, user.id)
kick_member(c::Client, guild::Integer, user::User) = kick_member(c, guild, user.id)
kick_member(c::Client, guild::Guild, user::Integer) = kick_member(c, guild.id, user)

"""
    add_role(c::Client, guild::Union{Guild, Integer}, user::Union{User, Integer}, role::Union{Role, Integer}) -> Response{Nothing}

Add a [`Role`](@ref) to the given [`Member`](@ref).
"""
function add_role(c::Client, guild::Integer, user::Integer, role::Integer)
    return Response{Nothing}(c, :PUT, "/guilds/$guild/members/$user/roles/$role")
end

add_role(c::Client, guild::Guild, user::User, role::Role) = add_role(c, guild.id, user.id, role.permissions)
add_role(c::Client, guild::Guild, user::User, role::Integer) = add_role(c, guild.id, user.id, role)
add_role(c::Client, guild::Guild, user::Integer, role::Role) = add_role(c, guild.id, user, role.permissions)
add_role(c::Client, guild::Guild, user::Integer, role::Integer) = add_role(c, guild.id, user, role)
add_role(c::Client, guild::Integer, user::User, role::Role) = add_role(c, guild, user.id, role.permissions)
add_role(c::Client, guild::Integer, user::User, role::Integer) = add_role(c, guild, user.id, role)
add_role(c::Client, guild::Integer, user::Integer, role::Role) = add_role(c, guild, user, role.permissions)

"""
    remove_role(c::Client, guild::Union{Guild, Integer}, user::Union{User, Integer}, role::Union{Role, Integer}) -> Response{Nothing}

Remove a [`Role`](@ref) from the given [`Member`](@ref).
"""
function remove_role(c::Client, guild::Integer, user::Integer, role::Integer)
    return Response{Nothing}(c, :DELETE, "/guilds/$guild/members/$user/roles/$role")
end

remove_role(c::Client, guild::Guild, user::User, role::Role) = remove_role(c, guild.id, user.id, role.permissions)
remove_role(c::Client, guild::Guild, user::User, role::Integer) = remove_role(c, guild.id, user.id, role)
remove_role(c::Client, guild::Guild, user::Integer, role::Role) = remove_role(c, guild.id, user, role.permissions)
remove_role(c::Client, guild::Guild, user::Integer, role::Integer) = remove_role(c, guild.id, user, role)
remove_role(c::Client, guild::Integer, user::User, role::Role) = remove_role(c, guild, user.id, role.permissions)
remove_role(c::Client, guild::Integer, user::User, role::Integer) = remove_role(c, guild, user.id, role)
remove_role(c::Client, guild::Integer, user::Integer, role::Role) = remove_role(c, guild, user, role.permissions)
