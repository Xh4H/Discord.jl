export get_invite,
        delete_invite

function beautify(c::Client, inv::Dict{String, Any})
    inv["guild"] = c.state.guilds[snowflake(inv["guild"]["id"])]
    inv["channel"] = c.state.channels[snowflake(inv["channel"]["id"])]

    return inv
end

"""
    get_invite(c::Client, code::String; with_counts::Bool=false) -> Invite

Retrieve an [`Invite`](@ref) with the given code. Optionally return with usage information
upon success or a Dict containing error information.
"""
function get_invite(c::Client, code::String; with_counts::Bool=false)
    err, data = request(c, "GET", "/invites/$code"; query=Dict("with_counts" => with_counts))

    return if err
        data
    else
        beautify(c, data) |> Invite
    end
end

"""
    delete_invite(c::Client, code::String) -> Invite

Delete an [`Invite`](@ref) with the given code
upon success or a Dict containing error information.
"""
function delete_invite(c::Client, code::String)
    err, data = request(c, "DELETE", "/invites/$code")

    return if err
        data
    else
        beautify(c, data) |> Invite
    end
end
