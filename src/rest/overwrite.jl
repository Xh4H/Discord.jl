export modify_overwrite,
        delete_overwrite

"""
    modify_overwrite(c::Client, channel::Snowflake, overwrite::Snowflake; params...) -> Response{Overwrite}

Modify a given [`Overwrite`](@ref) in the given [`DiscordChannel`](@ref) with the given parameters.

# Keywords
- `allow::Int`: the bitwise value of all allowed permissions.
- `deny::Int`: the bitwise value of all denied permissions.
- `type::AbstractString`: "member" for a user or "role" for a role.

More details [here](https://discordapp.com/developers/docs/resources/channel#edit-channel-permissions).
"""
function modify_overwrite(c::Client, overwrite::Snowflake, channel::Snowflake; params...)
    return Response{Overwrite}(c, :PUT, "/channels/$channel/permissions/$overwrite"; params...)
end

"""
    delete_overwrite(c::Client, overwrite::Snowflake, channel::Snowflake)) -> Response{Overwrite}

Delete a given [`Overwrite`](@ref) in the given [`DiscordChannel`](@ref).
"""
function delete_overwrite(c::Client, overwrite::Snowflake, channel::Snowflake)
    return Response{Overwrite}(c, :DELETE, "/channels/$channel/permissions/$overwrite")
end
