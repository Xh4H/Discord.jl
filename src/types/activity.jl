"""
The type of an [`Activity`](@ref).
More details [here](https://discordapp.com/developers/docs/topics/gateway#activity-object-activity-types).
"""
@enum ActivityType AT_GAME AT_STREAMING AT_LISTENING AT_UNKNOWN  # Supposed to only go to 2.

JSON.lower(at::ActivityType) = Int(at)

"""
Flags which indicate what an [`Activity`](@ref) payload contains.
More details [here](https://discordapp.com/developers/docs/topics/gateway#activity-object-activity-flags).
"""
@enum ActivityFlags begin
    AF_INSTANCE=1<<0
    AF_JOIN=1<<1
    AF_SPECTATE=1<<2
    AF_JOIN_REQUEST=1<<3
    AF_SYNC=1<<4
    AF_PLAY=1<<5
end

JSON.lower(af::ActivityFlags) = Int(af)

"""
Indicates the start and stop of an [`Activity`](@ref).
More details [here](https://discordapp.com/developers/docs/topics/gateway#activity-object-activity-timestamps).
"""
struct ActivityTimestamps
    start::Union{DateTime, Missing}
    stop::Union{DateTime, Missing}
    extra_fields::Dict{String, Any}
end

function ActivityTimestamps(d::Dict{String, Any})
    return ActivityTimestamps(
        haskey(d, "start") ? unix2datetime(d["start"] / 1000) : missing,
        haskey(d, "end") ? unix2datetime(d["end"] / 1000) : missing,
        extra_fields(ActivityTimestamps, d)
    )
end

function JSON.lower(at::ActivityTimestamps)
    d = Dict{String, Any}()
    if !ismissing(at.start)
        d["start"] = round(Int, datetime2unix(at.start) * 1000)
    end
    if !ismissing(at.stop)
        d["end"] = round(Int, datetime2unix(at.stop) * 1000)
    end
    return d
end

"""
The current party of an [`Activity`](@ref)'s player.
More details [here](https://discordapp.com/developers/docs/topics/gateway#activity-object-activity-party).
"""
@from_dict struct ActivityParty
    id::Union{String, Missing}
    size::Union{Vector{Int}, Missing}
end

"""
Images and hover text for an [`Activity`](@ref).
More details [here](https://discordapp.com/developers/docs/topics/gateway#activity-object-activity-assets).
"""
@from_dict struct ActivityAssets
    large_image::Union{String, Missing}
    large_text::Union{String, Missing}
    small_image::Union{String, Missing}
    small_text::Union{String, Missing}
end

"""
Secrets for Rich Presence joining and spectating of an [`Activity`](@ref).
More details [here](https://discordapp.com/developers/docs/topics/gateway#activity-object-activity-secrets).
"""
@from_dict struct ActivitySecrets
    join::Union{String, Missing}
    spectate::Union{String, Missing}
    match::Union{String, Missing}
end

"""
A [`User`](@ref) activity.
More details [here](https://discordapp.com/developers/docs/topics/gateway#activity-object).
"""
@from_dict struct Activity
    name::String
    type::ActivityType
    url::Union{String, Nothing, Missing}
    timestamps::Union{ActivityTimestamps, Missing}
    application_id::Union{Snowflake, Missing}
    details::Union{String, Nothing, Missing}
    state::Union{String, Nothing, Missing}
    party::Union{ActivityParty, Missing}
    assets::Union{ActivityAssets, Missing}
    secrets::Union{ActivitySecrets, Missing}
    instance::Union{Bool, Missing}
    flags::Union{Int, Missing}
end
