@enum PresenceStatus PS_IDLE PS_DND PS_ONLINE PS_OFFLINE

function PresenceStatus(ps::AbstractString)
    return if s == "idle"
        PS_IDLE
    elseif s == "dnd"
        PS_DND
    elseif s == "online"
        PS_ONLINE
    elseif s == "offline"
        PS_OFFLINE
    else
        s
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
    roles::Vector{Snowflake}
    game::Union{Activity, Missing}
    guild_id::Snowflake
    status::Union{PresenceStatus, String}
end

