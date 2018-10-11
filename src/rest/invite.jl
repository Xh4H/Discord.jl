export get_invite,
    delete_invite

"""
    get_invite(c::Client, code::AbstractString; with_counts::Bool=false) -> Response{Invite}

Get an [`Invite`](@ref) with the given code. If `with_counts` is set, the [`Invite`](@ref)
will contain approximate member counts.
"""
function get_invite(c::Client, code::AbstractString; with_counts::Bool=false)
    return Response{Invite}(c, :GET, "/invites/$code"; with_counts=with_counts)
    # TODO: Same as create_invite.
end

"""
    delete_invite(c::Client, code::AbstractString) -> Response{Invite}

Delete an [`Invite`](@ref) with the given code.
"""
function delete_invite(c::Client, code::AbstractString)
    return Response{Invite}(c, :DELETE, "/invites/$code")
end
