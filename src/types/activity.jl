export ActivityType,
    ActivityTimestamps,
    ActivityParty,
    ActivityAssets,
    ActivitySecrets,
    Activity

@enum ActivityType AT_GAME AT_STREAMING AT_LISTENING
JSON.lower(at::ActivityType) = Int(at)

@enum ActivityFlags begin
    AF_INSTANCE=1<<0
    AF_JOIN=1<<1
    AF_SPECTATE=1<<2
    AF_JOIN_REQUEST=1<<3
    AF_SYNC=1<<4
    AF_PLAY=1<<5
end
JSON.lower(af::ActivityFlags) = Int(af)

struct ActivityTimestamps
    start::Union{DateTime, Missing}
    stop::Union{DateTime, Missing}
end

function ActivityTimestamps(d::Dict)
    return ActivityTimestamps(
        haskey(d, "start") ? unix2datetime(d["start"] / 1000) : missing,
        haskey(d, "end") ? unix2datetime(d["end"] / 1000) : missing,
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

@from_dict struct ActivityParty
    id::Union{String, Missing}
    size::Union{Vector{Int}, Missing}
end

function JSON.lower(ap::ActivityParty)
    d = Dict{String, Any}()
    if !ismissing(ap.id)
        d["id"] = ap.id
    end
    if !ismissing(ap.size)
        d["size"] = ap.size
    end
    return d
end

@from_dict struct ActivityAssets
    large_image::Union{String, Missing}
    large_text::Union{String, Missing}
    small_image::Union{String, Missing}
    small_text::Union{String, Missing}
end

function JSON.lower(aa::ActivityAssets)
    d = Dict{String, Any}()
    if !ismissing(ap.large_image)
        d["large_image"] = ap.large_image
    end
    if !ismissing(ap.large_text)
        d["large_text"] = ap.large_text
    end
    if !ismissing(ap.small_image)
        d["small_image"] = ap.small_image
    end
    if !ismissing(ap.small_text)
        d["small_text"] = ap.small_text
    end
    return d
end

@from_dict struct ActivitySecrets
    join::Union{String, Missing}
    spectate::Union{String, Missing}
    match::Union{String, Missing}
end

function JSON.lower(as::ActivitySecrets)
    d = Dict{String, Any}()
    if !ismissing(as.join)
        d["join"] = as.join
    end
    if !ismissing(as.spectate)
        d["spectate"] = as.spectate
    end
    if !ismissing(as.match)
        d["match"] = as.match
    end
    return d
end

"""
A user activity.
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
    flags::Union{ActivityFlags, Missing}
end

function JSON.lower(a::Activity)
    d = Dict{String, Any}()
    for f in fieldnames(Activity)
        v = getfield(a, f)
        if !ismissing(v)
            d[string(f)] = v === nothing ? nothing : JSON.lower(v)
        end
    end
    return d
end
