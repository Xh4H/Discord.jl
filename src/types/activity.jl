export Activity

"""
An [`Activity`](@ref)'s type. Available values are `AT_GAME`, `AT_STREAMING`,
`AT_LISTENING`, and `AT_WATCHING`.
More details [here](https://discordapp.com/developers/docs/topics/gateway#activity-object-activity-types).
"""
@enum ActivityType AT_GAME AT_STREAMING AT_LISTENING AT_WATCHING
@boilerplate ActivityType :export :lower

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
@boilerplate ActivityFlags :export :lower

"""
The start and stop times of an [`Activity`](@ref).
More details [here](https://discordapp.com/developers/docs/topics/gateway#activity-object-activity-timestamps).
"""
struct ActivityTimestamps
    start::Optional{DateTime}
    stop::Optional{DateTime}
end
@boilerplate ActivityTimestamps :constructors :docs :lower :merge :mock

"""
The current party of an [`Activity`](@ref)'s player.
More details [here](https://discordapp.com/developers/docs/topics/gateway#activity-object-activity-party).
"""
struct ActivityParty
    id::Optional{String}
    size::Optional{Vector{Int}}
end
@boilerplate ActivityParty :constructors :docs :lower :merge :mock

"""
Images and hover text for an [`Activity`](@ref).
More details [here](https://discordapp.com/developers/docs/topics/gateway#activity-object-activity-assets).
"""
struct ActivityAssets
    large_image::Optional{String}
    large_text::Optional{String}
    small_image::Optional{String}
    small_text::Optional{String}
end
@boilerplate ActivityAssets :constructors :docs :lower :merge :mock

"""
Secrets for Rich Presence joining and spectating of an [`Activity`](@ref).
More details [here](https://discordapp.com/developers/docs/topics/gateway#activity-object-activity-secrets).
"""
struct ActivitySecrets
    join::Optional{String}
    spectate::Optional{String}
    match::Optional{String}
end
@boilerplate ActivitySecrets :constructors :docs :lower :merge :mock

"""
A [`User`](@ref) activity.
More details [here](https://discordapp.com/developers/docs/topics/gateway#activity-object).
"""
struct Activity
    name::String
    type::ActivityType
    url::OptionalNullable{String}
    timestamps::Optional{ActivityTimestamps}
    application_id::Optional{Snowflake}
    details::OptionalNullable{String}
    state::OptionalNullable{String}
    party::Optional{ActivityParty}
    assets::Optional{ActivityAssets}
    secrets::Optional{ActivitySecrets}
    instance::Optional{Bool}
    flags::Optional{Int}
end
@boilerplate Activity :constructors :docs :lower :merge :mock
