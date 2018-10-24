const PRESENCE_STATUSES = ["idle", "dnd", "online", "offline"]

"""
A [`User`](@ref)'s status sent in a [`Presence`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/channel#message-object-message-application-structure).
"""
@enum PresenceStatus PS_IDLE PS_DND PS_ONLINE PS_OFFLINE PS_UNKNOWN

function PresenceStatus(ps::AbstractString)
    i = findfirst(s -> s == ps, PRESENCE_STATUSES)
    return i === nothing ? PS_UNKNOWN : PresenceStatus(i - 1)
end

Base.string(ps::PresenceStatus) = PRESENCE_STATUSES[Int(ps) + 1]
JSON.lower(ps::PresenceStatus) = string(ps)

"""
A [`User`](@ref)'s presence.
More details [here](https://discordapp.com/developers/docs/topics/gateway#presence-update).
"""
struct Presence
    # TODO: These were optional but with no note about them so assume it was my mistake.
    user::User
    roles::Vector{Snowflake}
    game::Union{Activity, Nothing}
    guild_id::Snowflake
    status::PresenceStatus
    activities::Vector{Activity}
end
@boilerplate Presence :dict :lower :merge
