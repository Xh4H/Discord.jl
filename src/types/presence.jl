@enum PresenceStatus PS_IDLE PS_DND PS_ONLINE PS_OFFLINE

function PresenceStatus(ps::AbstractString)
    return if ps == "idle"
        PS_IDLE
    elseif ps == "dnd"
        PS_DND
    elseif ps == "online"
        PS_ONLINE
    elseif ps == "offline"
        PS_OFFLINE
    else
        ps
    end
end

function Base.:(==)(ps::PresenceStatus, s::AbstractString)
    return ps === PS_IDLE && s == "idle" ||
        ps === PS_DND && s == "dnd" ||
        ps === PS_ONLINE && s == "online" ||
        ps === PS_OFFLINE && s == "offline"
end

struct Presence
    user::User
    roles::Union{Vector{Snowflake}, Missing}
    game::Union{Activity, Nothing}
    guild_id::Union{Snowflake, Missing}
    status::Union{PresenceStatus, String}
end

"""
A user presence.
More details [here](https://discordapp.com/developers/docs/topics/gateway#presence-update).
"""
function Presence(d::Dict)
    return Presence(
        User(d["user"]),
        haskey(d, "roles") ? snowflake.(d["roles"]) : missing,
        d["game"] === nothing ? nothing : Activity(d["game"]),
        haskey(d, "roles") ? snowflake(d["guild_id"]) : missing,
        PresenceStatus(d["status"]),
    )
end

