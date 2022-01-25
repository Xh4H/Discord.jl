export get_current_user,
    get_user,
    modify_current_user,
    get_current_user_guilds,
    leave_guild,
    create_dm

"""
    get_current_user(c::Client) -> User

Get the [`Client`](@ref) [`User`](@ref).
"""
get_current_user(c::Client) = Response{User}(c, :GET, "/users/@me")

"""
    get_user(c::Client, user::Integer) -> User

Get a [`User`](@ref).
"""
get_user(c::Client, user::Integer) = Response{User}(c, :GET, "/users/$user")

"""
    modify_current_user(c::Client; kwargs...) -> User

Modify the [`Client`](@ref) [`User`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/user#modify-current-user).
"""
modify_current_user(c::Client; kwargs...) = Response{User}(c, :PATCH, "/users/@me"; body = kwargs)

"""
    get_user_guilds(c::Client; kwargs...) -> Vector{Guild}

Get a list of [`Guild`](@ref)s the [`Client`](@ref) [`User`](@ref) is a member of.
More details [here](https://discordapp.com/developers/docs/resources/user#get-current-user-guilds).
"""
get_current_user_guilds(c::Client; kwargs...) = Response{Vector{Guild}}(c, :GET, "/users/@me/guilds"; kwargs...)

"""
    leave_guild(c::Client, guild::Integer)

Leave a [`Guild`](@ref).
"""
leave_guild(c::Client, guild::Integer) = Response(c, :DELETE, "/users/@me/guilds/$guild")

"""
    create_dm(c::Client; kwargs...) -> DiscordChannel

Create a DM [`DiscordChannel`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/user#create-dm).
"""
create_dm(c::Client; kwargs...) = Response{DiscordChannel}(c, :POST, "/users/@me/channels"; body = kwargs)
