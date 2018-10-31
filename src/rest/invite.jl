"""
    get_invite(c::Client, invite::AbstractString; kwargs...} -> Invite

Get an [`Invite`](@ref) to a [`Guild`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/invite#get-invite).
"""
function get_invite(c::Client, invite::AbstractString; kwargs...)
    return Response{Invite}(c, :GET, "/invites/$invite"; kwargs...)
end

"""
    delete_invite(c::Client, invite::AbstractString) -> Invite

Delete an [`Invite`](@ref) to a [`Guild`](@ref).
"""
function delete_invite(c::Client, invite::AbstractString)
    return Response{Invite}(c, :DELETE, "/invites/$invite")
end
