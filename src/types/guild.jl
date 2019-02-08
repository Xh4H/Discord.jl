export Guild

"""
A [`Guild`](@ref)'s verification level.
More details [here](https://discordapp.com/developers/docs/resources/guild#guild-object-verification-level).
"""
@enum VerificationLevel VL_NONE VL_LOW VL_MEDIUM VL_HIGH VL_VERY_HIGH
@boilerplate VerificationLevel :export :lower

"""
A [`Guild`](@ref)'s default message notification level.
More details [here](https://discordapp.com/developers/docs/resources/guild#guild-object-default-message-notification-level).
"""
@enum MessageNotificationLevel MNL_ALL_MESSAGES MNL_ONLY_MENTIONS
@boilerplate MessageNotificationLevel :export :lower

"""
A [`Guild`](@ref)'s explicit content filter level.
More details [here](https://discordapp.com/developers/docs/resources/guild#guild-object-explicit-content-filter-level).
"""
@enum ExplicitContentFilterLevel ECFL_DISABLED ECFL_MEMBERS_WITHOUT_ROLES ECFL_ALL_MEMBERS
@boilerplate ExplicitContentFilterLevel :export :lower

"""
A [`Guild`](@ref)'s MFA level.
More details [here](https://discordapp.com/developers/docs/resources/guild#guild-object-mfa-level).
"""
@enum MFALevel ML_NONE ML_ELEVATED
@boilerplate MFALevel :export :lower

"""
A Discord guild (server).
Can either be an [`UnavailableGuild`](@ref) or a [`Guild`](@ref).
"""
abstract type AbstractGuild end
function AbstractGuild(; kwargs...)
    return if get(kwargs, :unavailable, length(kwargs) <= 2) === true
        UnavailableGuild(; kwargs...)
    else
        Guild(; kwargs...)
    end
end
AbstractGuild(d::Dict{Symbol, Any}) = AbstractGuild(; d...)
mock(::Type{AbstractGuild}) = mock(rand(Bool) ? UnavailableGuild : Guild)

"""
An unavailable Discord guild (server).
More details [here](https://discordapp.com/developers/docs/resources/guild#unavailable-guild-object).
"""
struct UnavailableGuild <: AbstractGuild
    id::Snowflake
    unavailable::Optional{Bool}
end
@boilerplate UnavailableGuild :constructors :docs :lower :merge :mock

"""
A Discord guild (server).
More details [here](https://discordapp.com/developers/docs/resources/guild#guild-object).
"""
struct Guild <: AbstractGuild
    id::Snowflake
    name::String
    icon::Nullable{String}
    splash::OptionalNullable{String}
    owner::Optional{Bool}
    owner_id::Optional{Snowflake}  # Missing in Invite.
    permissions::Optional{Int}
    region::Optional{String}  # Invite
    afk_channel_id::OptionalNullable{Snowflake}  # Invite
    afk_timeout::Optional{Int}  # Invite
    embed_enabled::Optional{Bool}
    embed_channel_id::OptionalNullable{Snowflake}  # Not supposed to be nullable.
    verification_level::Optional{VerificationLevel}
    default_message_notifications::Optional{MessageNotificationLevel}  # Invite
    explicit_content_filter::Optional{ExplicitContentFilterLevel}  # Invite
    roles::Optional{Vector{Role}}  # Invite
    emojis::Optional{Vector{Emoji}}  # Invite
    features::Optional{Vector{String}}
    mfa_level::Optional{MFALevel}  # Invite
    application_id::OptionalNullable{Snowflake}  # Invite
    widget_enabled::Optional{Bool}
    widget_channel_id::OptionalNullable{Snowflake}  # Not supposed to be nullable.
    system_channel_id::OptionalNullable{Snowflake}  # Invite
    joined_at::Optional{DateTime}
    large::Optional{Bool}
    unavailable::Optional{Bool}
    member_count::Optional{Int}
    voice_states::Optional{Vector{VoiceState}}
    members::Optional{Vector{Member}}
    channels::Optional{Vector{DiscordChannel}}
    presences::Optional{Vector{Presence}}
    djl_users::Optional{Set{Snowflake}}
    djl_channels::Optional{Set{Snowflake}}
end
@boilerplate Guild :constructors :docs :lower :merge :mock

Base.merge(x::UnavailableGuild, y::Guild) = y
Base.merge(x::Guild, y::UnavailableGuild) = x
