export get_invite,
    delete_invite

"""
    get_invite(c::Client, invite::AbstractString; kwargs...} -> Invite

Get an [`Invite`](@ref) to a [`Guild`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/invite#get-invite).
"""
get_invite(c::Client, invite::AbstractString; kwargs...) = Response{Invite}(c, :GET, "/invites/$invite"; kwargs...)

"""
    delete_invite(c::Client, invite::AbstractString) -> Invite

Delete an [`Invite`](@ref) to a [`Guild`](@ref).
"""
delete_invite(c::Client, invite::AbstractString) = Response{Invite}(c, :DELETE, "/invites/$invite")
