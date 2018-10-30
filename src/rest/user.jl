export get_user,
    edit_client,
    get_connections,
    get_user_guilds,
    leave_guild,
    create_dm,
    create_group

"""
    get_user(c::Client, user::Union{User, Integer}) -> Response{User}

Get a [`User`](@ref).
"""
get_user(c::Client, user::Integer) = Response{User}(c, :GET, "/users/$user")
get_user(c::Client, u::User) = get_user(c, u.id)

"""
    edit_client(c::Client; params...) -> Response{User}

Modify the [`Client`](@ref) user.

# Keywords
- `username::AbstractString`: Username of the client.
- `avatar::AbstractString`: Avatar data string.

More details [here](https://discordapp.com/developers/docs/resources/user#modify-current-user).
"""
function edit_client(c::Client; params...)
    return Response{User}(c, :PATCH, "/users/@me"; body=params)
end

"""
    get_connections(c::Client) -> Response{Vector{Connection}}

Get the [`Client`](@ref)'s [`Connection`](@ref)s.
More details [here](https://discordapp.com/developers/docs/resources/user#get-user-connections).
"""
get_connections(c::Client) = Response{User}(c, :GET, "/users/@me/connections")

"""
    get_user_guilds(c::Client; params...) -> Response{Vector{AbstractGuild}}

Get a Vector of [`AbstractGuild`](@ref)s the current user is a member of.

# Keywords
- `before::Integer`: Get guilds before this guild ID.
- `after::Integer`: Get guilds after this guild ID.
- `limit::Integer`: Max number of guilds to return (1-100). Defaults to 100.

More details [here](https://discordapp.com/developers/docs/resources/user#get-current-user-guilds).
"""
function get_user_guilds(c::Client; params...)
    return Response{AbstractGuild}(
        c,
        :GET,
        "/users/@me/connections";
        params...,
    )
end

"""
    create_dm(c::Client, user::Integer) -> Response{DiscordChannel}

Create a DM [`DiscordChannel`](@ref).
"""
function create_dm(c::Client, user::Integer)
    return Response{DiscordChannel}(
        c,
        :POST,
        "/users/@me/channels";
        body=Dict("recipient_id" => user),
    )
end

create_dm(c::Client, user::User) = create_dm(c, user.id)

"""
    create_group(c::Client; params...) -> Response{DiscordChannel}

Create a group DM [`DiscordChannel`](@ref).

# Keywords
- `access_tokens::Vector`: Access tokens of users that have granted your app the `gdm.join`
   scope.
- `nicks::Dict`: A dictionary of [`User`](@ref) IDs to their respective nicknames.
"""
function create_group(c::Client; params...)
    return Response{DiscordChannel}(
        c,
        :POST,
        "/users/@me/channels";
        body=params,
    )
end

# Get User DMs not supported for bots
# More info here https://discordapp.com/developers/docs/resources/user#get-user-dms
