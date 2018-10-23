"""
The type of an [`AuditLogEntry`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/audit-log#audit-log-entry-object).
"""
@from_dict struct AuditLogEntry
    target_id::Union{String, Null}
    changes::Union{Dict, Missing} # https://discordapp.com/developers/docs/resources/audit-log#audit-log-change-object-audit-log-change-key
    user_id::Snowflake
    id::Snowflake
    action_type::AuditLogEvents
    options::Union{String, Missing}
    reason::Union{String, Missing}
end

"""
The type of an [`AuditLog`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/audit-log#audit-log-object).
"""
@from_dict struct AuditLog
    webhooks::Vector{Webhook}
    users::Vector{User}
    audit_log_entries::Vector{AuditLogEntry}
end

"""
[`AuditLog`](@ref) events.
More details [here](https://discordapp.com/developers/docs/resources/audit-log#audit-log-entry-object-audit-log-events).
"""
@enum AuditLogEvents begin
    GUILD_UPDATE=1
    CHANNEL_CREATE=10
    CHANNEL_UPDATE=11
    CHANNEL_DELETE=12
    CHANNEL_OVERWRITE_CREATE=13
    CHANNEL_OVERWRITE_UPDATE=14
    CHANNEL_OVERWRITE_DELETE=15
    MEMBER_KICK=20
    MEMBER_PRUNE=21
    MEMBER_BAN_ADD=22
    MEMBER_BAN_REMOVE=23
    MEMBER_UPDATE=24
    MEMBER_ROLE_UPDATE=25
    ROLE_CREATE=30
    ROLE_UPDATE=31
    ROLE_DELETE=32
    INVITE_CREATE=40
    INVITE_UPDATE=41
    INVITE_DELETE=42
    WEBHOOK_CREATE=50
    WEBHOOK_UPDATE=51
    WEBHOOK_DELETE=52
    EMOJI_CREATE=60
    EMOJI_UPDATE=61
    EMOJI_DELETE=62
    MESSAGE_DELETE=72
end
