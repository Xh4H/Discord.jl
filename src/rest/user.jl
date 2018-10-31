"""
    get_current_user(c::Client) -> User

Get the [`Client`](@ref)'s [`User`](@ref).
"""
function get_current_user(c::Client)
    return Response{User}(c, :GET, "/users/@me")
end

"""
    get_user(c::Client, user::Integer) -> User

Get a [`User`](@ref).
"""
function get_user(c::Client, user::Integer)
    return Response{User}(c, :GET, "/users/$user")
end

"""
    modify_current_user(c::Client; kwargs...) -> User

Modify the [`Client`](@ref)'s [`User`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/user#modify-current-user).
"""
function modify_current_user(c::Client; kwargs...)
    return Response{User}(c, :PATCH, "/users/@me"; body=kwargs)
end

"""
    get_user_guilds(c::Client; kwargs...) -> Vector{Guild}

Get a list of [`Guild`](@ref)s the [`Client`](@ref)'s [`User`](@ref) is a member of.
More details [here](https://discordapp.com/developers/docs/resources/user#get-current-user-guilds).
"""
function get_current_user_guilds(c::Client; kwargs...)
    return Response{Guild}(c, :GET, "/users/@me/connections"; kwargs...)
end

"""
    leave_guild(c::Client, guild::Integer)

Leave a [`Guild`](@ref).
"""
function leave_guild(c::Client, guild::Integer)
    return Response(c, :DELETE, "/users/@me/guilds/$guild")
end

"""
    create_dm(c::Client; kwargs...) -> DiscordChannel

Create a DM [`DiscordChannel`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/user#create-dm).
"""
function create_dm(c::Client; kwargs...)
    return Response{DiscordChannel}(c, :POST, "/users/@me/channels"; body=kwargs)
end

"""
    create_group_dm(c::Client; kwargs...) -> DiscordChannel

Create a group DM [`DiscordChannel`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/user#create-group-dm).
"""
function create_group_dm(c::Client; kwargs...)
    return Response{DiscordChannel}(c, :POST, "/users/@me/channels"; body=kwargs)
end

"""
    get_user_connections(c::Client) -> Vector{Connection}

Get the [`Client`](@ref)'s [`Connection`](@ref)s.
More details [here](https://discordapp.com/developers/docs/resources/user#get-user-connections).
"""
function get_user_connections(c::Client)
    return Response{Connection}(c, :GET, "/users/@me/connections")
end
