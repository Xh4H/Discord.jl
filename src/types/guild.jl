@enum VerificationLevel VL_NONE VL_LOW VL_MEDIUM VL_HIGH VL_VERY_HIGH

JSON.lower(vf::VerificationLevel) = Int(vf)

@enum MessageNotificationLevel MNL_ALL_MESSAGES MNL_ONLY_MENTIONS

JSON.lower(mnl::MessageNotificationLevel) = Int(mnl)

@enum ExplicitContentFilterLevel ECFL_DISABLED ECFL_MEMBERS_WITHOUT_ROLES ECFL_ALL_MEMBERS

JSON.lower(ecfl::ExplicitContentFilterLevel) = Int(ecfl)

@enum MFALevel ML_NONE ML_ELEVATED

JSON.lower(ml::MFALevel) = Int(ml)

"""
A guild (server).
Can either be an [`UnavailableGuild`](@ref) or a [`Guild`](@ref).
"""
abstract type AbstractGuild end

function AbstractGuild(d::Dict{String, Any})
    return d["unavailable"] === true ? UnavailableGuild(d) : Guild(d)
end

"""
An unavailable guild (server).
More details [here](https://discordapp.com/developers/docs/resources/guild#unavailable-guild-object).
"""
@from_dict struct UnavailableGuild <: AbstractGuild
    id::Snowflake
    unavailable::Bool
end

"""
A guild (server).
More details [here](https://discordapp.com/developers/docs/resources/guild#guild-object).
"""
@from_dict struct Guild <: AbstractGuild
    id::Snowflake
    name::String
    icon::Union{String, Nothing}
    splash::Union{String, Nothing}
    owner::Union{Bool, Missing}
    owner_id::Snowflake
    permissions::Union{Int, Missing}
    region::String
    afk_channel_id::Union{Snowflake, Nothing}
    afk_timeout::Int
    embed_enabled::Union{Bool, Missing}
    embed_channel_id::Union{Snowflake, Missing}
    verification_level::VerificationLevel
    default_message_notifications::MessageNotificationLevel
    explicit_content_filter::ExplicitContentFilterLevel
    roles::Vector{Role}
    emojis::Vector{Emoji}
    features::Vector{String}
    mfa_level::MFALevel
    application_id::Union{Snowflake, Nothing}
    widget_enabled::Union{Bool, Missing}
    widget_channel_id::Union{Snowflake, Missing}
    system_channel_id::Union{Snowflake, Nothing}
    joined_at::Union{DateTime, Missing}
    large::Union{Bool, Missing}
    unavailable::Union{Bool, Missing}
    member_count::Union{Int, Missing}
    voice_states::Union{Vector{VoiceState}, Missing}
    members::Union{Vector{Member}, Missing}
    channels::Union{Vector{DiscordChannel}, Missing}
    presences::Union{Vector{Presence}, Missing}
end
