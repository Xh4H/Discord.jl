export modify_overwrite,
    delete_overwrite

# TODO: These functions might make more sense as f(c, channel, overwrite; params...).
# Most functions on messages for example use that convention.

"""
    modify_overwrite(
        c::Client,
        channel::Integer,
        overwrite::Integer;
        params...,
    ) -> Response{Overwrite}

Modify a given [`Overwrite`](@ref) in the given [`DiscordChannel`](@ref).

# Keywords
- `allow::Int`: the bitwise value of all allowed permissions.
- `deny::Int`: the bitwise value of all denied permissions.
- `type::AbstractString`: "member" for a user or "role" for a role.

More details [here](https://discordapp.com/developers/docs/resources/channel#edit-channel-permissions).
"""
function modify_overwrite(c::Client, overwrite::Integer, channel::Integer; params...)
    return Response{Overwrite}(
        c,
        :PUT,
        "/channels/$channel/permissions/$overwrite";
        params...,
    )
end

"""
    delete_overwrite(
        c::Client,
        overwrite::Integer,
        channel::Integer
    ) -> Response{Overwrite}

Delete a given [`Overwrite`](@ref) in the given [`DiscordChannel`](@ref).
"""
function delete_overwrite(c::Client, overwrite::Integer, channel::Integer)
    return Response{Overwrite}(c, :DELETE, "/channels/$channel/permissions/$overwrite")
end
