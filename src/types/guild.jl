@enum VerificationLevel VL_NONE VL_LOW VL_MEDIUM VL_HIGH VL_VERY_HIGH
@enum MessageNotificationLevel MNL_ALL_MESSAGES MNL_ONLY_MENTIONS
@enum ExplicitContentFilterLevel ECFL_DISABLED ECFL_MEMBERS_WITHOUT_ROLES ECFL_ALL_MEMBERS
@enum MFALevel ML_NONE ML_ELEVATED

abstract type AbstractGuild end

AbstractGuild(d::Dict) = d["unavailable"] === true ? UnavailableGuild(d) : Guild(d)

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
    icon::Union{String, Missing}
    splash::Union{String, Missing}
    owner::Union{Bool, Nothing}
    owner_id::Snowflake
    permissions::Union{Int, Nothing}
    region::String
    afk_channel_id::Union{Snowflake, Missing}
    afk_timeout::Int
    embed_enabled::Union{Bool, Nothing}
    embed_channel_id::Union{Snowflake, Nothing}
    verification_level::VerificationLevel
    default_message_notifications::MessageNotificationLevel
    explicit_content_filter::ExplicitContentFilterLevel
    roles::Vector{Role}
    emojis::Vector{Emoji}
    features::Vector{String}
    mfa_level::MFALevel
    application_id::Union{Snowflake, Missing}
    widget_enabled::Union{Bool, Nothing}
    widget_channel_id::Union{Snowflake, Nothing}
    system_channel_id::Union{Snowflake, Missing}
    joined_at::Union{DateTime, Nothing}
    large::Union{Bool, Nothing}
    unavailable::Union{Bool, Nothing}
    member_count::Union{Int, Nothing}
    voice_states::Union{Vector{VoiceState}, Nothing}
    members::Union{Vector{GuildMember}, Nothing}
    channels::Union{Vector{Channel}, Nothing}
    presences::Union{Vector{Presence}, Nothing}
end

@from_dict struct GuildEmbed
    enabled::Bool
    channel_id::Union{Snowflake, Missing}
end
