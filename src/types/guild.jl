"""
A [`Guild`](@ref)'s verification level.
More details [here](https://discordapp.com/developers/docs/resources/guild#guild-object-verification-level).
"""
@enum VerificationLevel VL_NONE VL_LOW VL_MEDIUM VL_HIGH VL_VERY_HIGH
@boilerplate VerificationLevel :lower

"""
A [`Guild`](@ref)'s default message notification level.
More details [here](https://discordapp.com/developers/docs/resources/guild#guild-object-default-message-notification-level).
"""
@enum MessageNotificationLevel MNL_ALL_MESSAGES MNL_ONLY_MENTIONS
@boilerplate MessageNotificationLevel :lower

"""
A [`Guild`](@ref)'s explicit content filter level.
More details [here](https://discordapp.com/developers/docs/resources/guild#guild-object-explicit-content-filter-level).
"""
@enum ExplicitContentFilterLevel ECFL_DISABLED ECFL_MEMBERS_WITHOUT_ROLES ECFL_ALL_MEMBERS
@boilerplate ExplicitContentFilterLevel :lower

"""
A [`Guild`](@ref)'s MFA level.
More details [here](https://discordapp.com/developers/docs/resources/guild#guild-object-mfa-level).
"""
@enum MFALevel ML_NONE ML_ELEVATED
@boilerplate MFALevel :lower

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
struct UnavailableGuild <: AbstractGuild
    id::Snowflake
    unavailable::Bool
end
@boilerplate UnavailableGuild :dict :docs :lower :merge

"""
A guild (server).
More details [here](https://discordapp.com/developers/docs/resources/guild#guild-object).
"""
struct Guild <: AbstractGuild
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
    embed_channel_id::Union{Snowflake, Missing, Nothing}  # Not supposed to be nullable.
    verification_level::VerificationLevel
    default_message_notifications::MessageNotificationLevel
    explicit_content_filter::ExplicitContentFilterLevel
    roles::Vector{Role}
    emojis::Vector{Emoji}
    features::Vector{String}
    mfa_level::MFALevel
    application_id::Union{Snowflake, Nothing}
    widget_enabled::Union{Bool, Missing}
    widget_channel_id::Union{Snowflake, Missing, Nothing}  # Not supposed to be nullable.
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
@boilerplate Guild :dict :docs :lower :merge
