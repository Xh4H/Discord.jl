export get_invite,
    delete_invite

"""
    get_invite(
        c::Client,
        invite::Union{Invite, AbstractString};
        with_counts::Bool=false,
    ) -> Response{Invite}

Get an [`Invite`](@ref). If `with_counts` is set, the [`Invite`](@ref) will contain
approximate member counts.
"""
function get_invite(c::Client, invite::AbstractString; with_counts::Bool=false)
    return Response{Invite}(c, :GET, "/invites/$invite"; with_counts=with_counts)
    # See create_invite TODO.
end

function get_invite(c::Client, inv::Invite; with_counts::Bool=false)
    return get_invite(c, inv.code; with_counts=with_counts)
end

"""
    delete_invite(c::Client, invite::Union{Invite, AbstractString}) -> Response{Invite}

Delete an [`Invite`](@ref).
"""
function delete_invite(c::Client, invite::AbstractString)
    return Response{Invite}(c, :DELETE, "/invites/$invite")
end

delete_invite(c::Client, inv::Invite) = delete_invite(c, inv.code)
