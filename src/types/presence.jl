const PRESENCE_STATUSES = ["idle", "dnd", "online", "offline"]

"""
A [`User`](@ref)'s status sent in a [`Presence`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/channel#message-object-message-application-structure).
"""
@enum PresenceStatus PS_IDLE PS_DND PS_ONLINE PS_OFFLINE PS_UNKNOWN

function PresenceStatus(x::AbstractString)
    i = findfirst(s -> s == x, PRESENCE_STATUSES)
    return i === nothing ? PS_UNKNOWN : PresenceStatus(i - 1)
end

Base.string(x::PresenceStatus) = PRESENCE_STATUSES[Int(x) + 1]
JSON.lower(x::PresenceStatus) = string(x)

"""
A [`User`](@ref)'s presence.
More details [here](https://discordapp.com/developers/docs/topics/gateway#presence-update).
"""
struct Presence
    user::User
    roles::Union{Vector{Snowflake}, Missing}
    game::Union{Activity, Nothing}
    guild_id::Union{Snowflake, Missing}
    status::PresenceStatus
    activities::Vector{Activity}
end
@boilerplate Presence :dict :docs :lower :merge
