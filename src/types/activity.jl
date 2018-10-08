@enum ActivityType AT_GAME AT_STREAMING AT_LISTENING
@enum ActivityFlags begin
    AF_INSTANCE=1<<0
    AF_JOIN=1<<1
    AF_SPECTATE=1<<2
    AF_JOIN_REQUEST=1<<3
    AF_SYNC=1<<4
    AF_PLAY=1<<5
end

struct ActivityTimestamps
    start::Union{DateTime, Nothing}
    stop::Union{DateTime, Nothing}
end

function ActivityTimestamps(d::Dict)
    return ActivityTimestamps(
        d["start"] === nothing ? nothing : unix2datetime(d["start"]),
        d["end"] === nothing ? nothing : unix2datetime(d["end"]),
    )
end

@from_dict struct ActivityParty
    id::Union{String, Nothing}
    size::Union{Vector{Int}, Nothing}
end

@from_dict struct ActivityAssets
    large_image::Union{String, Nothing}
    large_text::Union{String, Nothing}
    small_image::Union{String, Nothing}
    small_text::Union{String, Nothing}
end

@from_dict struct ActivitySecrets
    join::Union{String, Nothing}
    spectate::Union{String, Nothing}
    match::Union{String, Nothing}
end

"""
A user activity.
More details [here](https://discordapp.com/developers/docs/topics/gateway#activity-object).
"""
@from_dict struct Activity
    name::String
    type::ActivityType
    url::Union{String, Nothing, Missing}
    timestamps::Union{ActivityTimestamps, Nothing}
    application_id::Union{Snowflake, Nothing}
    details::Union{String, Nothing, Missing}
    state::Union{String, Nothing, Missing}
    party::Union{ActivityParty, Nothing}
    assets::Union{ActivityAssets, Nothing}
    secrets::Union{ActivitySecrets, Nothing}
    instance::Union{Bool, Nothing}
    flags::Union{ActivityFlags, Nothing}
end
