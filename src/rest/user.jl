export get_user,
        modify_client,
        get_connections,
        get_user_guilds,
        leave_guild,
        create_dm,
        create_group

"""
    get_user(c::Client, user::Union{User, Integer}) -> Response{User}

Get a [`User`](@ref).
"""
function get_user(c::Client, user::Integer)
    return if haskey(c.state.users, user)
        Response{User}(c.state.users[user])
    else
        Response{User}(c, :GET, "/users/$user")
    end
end

get_user(c::Client, user::User) = get_user(c, user.id)

"""
    modify_client(c::Client; params...) -> Response{User}

Modify the local Client / Bot.

# Keywords
- `username::AbstractString`: Username of the client.
- `avatar::AbstractString`: Avatar data string.

More details [here](https://discordapp.com/developers/docs/resources/user#modify-current-user).
"""
function modify_client(c::Client; params...)
    return Response{User}(c, :PATCH, "/users/@me"; body=params)
end

"""
    get_connections(c::Client) -> Response{Vector{Connection}}

Get a Vector of [`Connection`](@ref)s for the local Client / Bot.

More details [here](https://discordapp.com/developers/docs/resources/user#get-user-connections).
"""
get_connections(c::Client) = Response{User}(c, :GET, "/users/@me/connections")

"""
    get_user_guilds(c::Client; params...) -> Response{Vector{AbstractGuild}}

Get a Vector of [`AbstractGuild`](@ref)s the current user is a member of.

# Query Params
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
        params...
    )
end

"""
    leave_guild(c::Client, guild::Union{AbstractGuild, Integer}) -> Response{Nothing}

Leave a [`Guild`](@ref).
"""
function leave_guild(c::Client, guild::Integer)
    return Response{Nothing}(
        c,
        :DELETE,
        "/users/@me/guilds/$(guild)"
    )
end

leave_guild(c::Client, guild::AbstractGuild) = leave_guild(c, guild.id)

"""
    create_dm(c::Client, user::Integer) -> Response{DiscordChannel}

Create a DM [`DiscordChannel`](@ref).
"""
function create_dm(c::Client, user::Integer)
    return Response{DiscordChannel}(
        c,
        :POST,
        "/users/@me/channels";
        body=Dict("recipient_id" => user)
    )
end

create_dm(c::Client, user::User) = leave_guild(c, user.id)

"""
    create_group(c::Client; params...) -> Response{DiscordChannel}

Create a group DM [`DiscordChannel`](@ref).

# Keywords
- `access_tokens::Array`: Access tokens of users that have granted your app the `gdm.join` scope.
- `nicks::Dict`: A dictionary of [`User`](@ref) IDs to their respective nicknames.
"""
function create_group(c::Client; params...)
    return Response{DiscordChannel}(
        c,
        :POST,
        "/users/@me/channels";
        body=params
    )
end

# Get User DMs not supported for bots
# More info here https://discordapp.com/developers/docs/resources/user#get-user-dms
