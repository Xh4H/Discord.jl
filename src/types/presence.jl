const PRESENCE_STATUSES = ["idle", "dnd", "online", "offline"]

@enum PresenceStatus PS_IDLE PS_DND PS_ONLINE PS_OFFLINE

function PresenceStatus(ps::AbstractString)
    i = findfirst(s -> s == ps, PRESENCE_STATUSES)
    return i === nothing ? ps : PresenceStatus(i - 1)
end

Base.string(ps::PresenceStatus) = PRESENCE_STATUSES[Int(ps) + 1]

JSON.lower(ps::PresenceStatus) = string(ps)

struct Presence
    user::User
    roles::Union{Vector{Snowflake}, Missing}
    game::Union{Activity, Nothing}
    guild_id::Union{Snowflake, Missing}
    status::Union{PresenceStatus, String}
    extra_fields::Dict{String, Any}
end

"""
A user presence.
More details [here](https://discordapp.com/developers/docs/topics/gateway#presence-update).
"""
function Presence(d::Dict{String, Any})
    return Presence(
        User(d["user"]),
        haskey(d, "roles") ? snowflake.(d["roles"]) : missing,
        d["game"] === nothing ? nothing : Activity(d["game"]),
        haskey(d, "roles") ? snowflake(d["guild_id"]) : missing,
        PresenceStatus(d["status"]),
        extra_fields(Presence, d),
    )
end
