export retrieve

function beautify(c::Client, inv::Dict)
    g = inv["guild"]
    ch = inv["channel"]
    println(c.state.guilds)
    inv["guild"] = c.state.guilds[snowflake(g["id"])]
    inv["channel"] = c.state.channels[snowflake(ch["id"])]

    @show inv
    return inv
end

"""
    retrieve(c::Client, code::String; with_counts::Bool=false) -> Message

Retrieve an [`Invite`](@ref) with the given code. Optionally return with usage information.
"""
function retrieve(c::Client, code::String; with_counts::Bool=false)
    try
        data = create_request(c, "GET", "/invites/$code", "", Dict("with_counts" => with_counts))
        println(beautify(c, data))

        return beautify(c, data) |> Invite
    catch e
        println(e)
    end

end
