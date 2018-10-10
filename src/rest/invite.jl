export get_invite,
        delete_invite

function beautify(c::Client, inv::Dict{String, Any})
    inv["guild"] = c.state.guilds[snowflake(inv["guild"]["id"])]
    inv["channel"] = c.state.channels[snowflake(inv["channel"]["id"])]

    return inv
end

"""
    get_invite(c::Client, code::String; with_counts::Bool=false) -> Invite

Retrieve an [`Invite`](@ref) with the given code. Optionally return with usage information.
"""

function get_invite(c::Client, code::String; with_counts::Bool=false)
    inv = request(c, "GET", "/invites/$code"; query=Dict("with_counts" => with_counts))
    return beautify(c, inv) |> Invite
end

"""
    delete_invite(c::Client, code::String) -> Invite

Delete an [`Invite`](@ref) with the given code.
"""

function delete_invite(c::Client, code::String)
    inv = request(c, "DELETE", "/invites/$code")
    return beautify(c, inv) |> Invite
end
