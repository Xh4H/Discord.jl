export AuditLog

const AUDIT_LOG_CHANGE_TYPES = Dict(
    "name"                          => (String, Guild),
    "icon_hash"                     => (String, Guild) ,
    "splash_hash"                   => (String, Guild),
    "owner_id"                      => (Snowflake, Guild),
    "region"                        => (String, Guild),
    "afk_channel_id"                => (Snowflake, Guild),
    "afk_timeout"                   => (Int, Guild),
    "mfa_level"                     => (MFALevel, Guild),
    "verification_level"            => (VerificationLevel, Guild),
    "explicit_content_filter"       => (ExplicitContentFilterLevel, Guild),
    "default_message_notifications" => (MessageNotificationLevel, Guild),
    "vanity_url_code"               => (String, Guild),
    "\$add"                         => (Vector{Role}, Guild),
    "\$remove"                      => (Vector{Role}, Guild),
    "prune_delete_days"             => (Int, Guild),
    "widget_enabled"                => (Bool, Guild),
    "widget_channel_id"             => (Snowflake, Guild),
    "position"                      => (Int, DiscordChannel),
    "topic"                         => (String, DiscordChannel),
    "bitrate"                       => (Int, DiscordChannel),
    "permission_overwrites"         => (Vector{Overwrite}, DiscordChannel),
    "nsfw"                          => (Bool, DiscordChannel),
    "application_id"                => (Snowflake, DiscordChannel),
    "permissions"                   => (Int, Role),
    "color"                         => (Int, Role),
    "hoist"                         => (Bool, Role),
    "mentionable"                   => (Bool, Role),
    "allow"                         => (Int, Role),
    "deny"                          => (Int, Role),
    "code"                          => (String, Invite),
    "channel_id"                    => (Snowflake, Invite),
    "inviter_id"                    => (Snowflake, Invite),
    "max_uses"                      => (Int, Invite),
    "uses"                          => (Int, Invite),
    "max_age"                       => (Int, Invite),
    "temporary"                     => (Bool, Invite),
    "deaf"                          => (Bool, User),
    "mute"                          => (Bool, User),
    "nick"                          => (String, User),
    "avatar_hash"                   => (String, User),
    "id"                            => (Snowflake, Any),
    "type"                          => (Any, Any),
    # Undocumented.
    "rate_limit_per_user"           => (Int, DiscordChannel),
)

const OVERWRITE_TYPES = ["member", "role"]

"""
[`AuditLog`](@ref) action types.
More details [here](https://discordapp.com/developers/docs/resources/audit-log#audit-log-entry-object-audit-log-events).
"""
@enum ActionType  begin
    AT_GUILD_UPDATE=1
    AT_CHANNEL_CREATE=10
    AT_CHANNEL_UPDATE=11
    AT_CHANNEL_DELETE=12
    AT_CHANNEL_OVERWRITE_CREATE=13
    AT_CHANNEL_OVERWRITE_UPDATE=14
    AT_CHANNEL_OVERWRITE_DELETE=15
    AT_MEMBER_KICK=20
    AT_MEMBER_PRUNE=21
    AT_MEMBER_BAN_ADD=22
    AT_MEMBER_BAN_REMOVE=23
    AT_MEMBER_UPDATE=24
    AT_MEMBER_ROLE_UPDATE=25
    AT_ROLE_CREATE=30
    AT_ROLE_UPDATE=31
    AT_ROLE_DELETE=32
    AT_INVITE_CREATE=40
    AT_INVITE_UPDATE=41
    AT_INVITE_DELETE=42
    AT_WEBHOOK_CREATE=50
    AT_WEBHOOK_UPDATE=51
    AT_WEBHOOK_DELETE=52
    AT_EMOJI_CREATE=60
    AT_EMOJI_UPDATE=61
    AT_EMOJI_DELETE=62
    AT_MESSAGE_DELETE=72
end
@boilerplate ActionType :lower

"""
An [`Overwrite`](@ref)'s type.
More details [here](https://discordapp.com/developers/docs/resources/audit-log#audit-log-entry-object-optional-audit-entry-info).
"""
@enum OverwriteType OT_MEMBER OT_ROLE OT_UNKNOWN

function OverwriteType(x::AbstractString)
    i = findfirst(s -> s == x, OVERWRITE_TYPES)
    return i === nothing ? OT_UNKNOWN : OverwriteType(i - 1)
end

Base.string(x::OverwriteType) = OVERWRITE_TYPES[Int(x) + 1]
JSON.lower(x::OverwriteType) = string(x)

"""
A change item in an [`AuditLogEntry`](@ref).

The first type parameter is the type of `new_value` and `old_value`. The second is the type
of the entity that `new_value` and `old_value` belong(ed) to.

More details [here](https://discordapp.com/developers/docs/resources/audit-log#audit-log-change-object).
"""
struct AuditLogChange{T, U}
    new_value::Union{T, Missing}
    old_value::Union{T, Missing}
    key::String
    type::Type{U}
end
@boilerplate AuditLogChange :docs

function AuditLogChange(d::Dict{String, Any})
    return if haskey(AUDIT_LOG_CHANGE_TYPES, d["key"])
        T, U = AUDIT_LOG_CHANGE_TYPES[d["key"]]
        func = if T === Any
            identity
        elseif T === Snowflake
            snowflake
        elseif T <: Vector
            eltype(T)
        else
            T
        end

        new_value = if haskey(d, "new_value")
            d["new_value"] isa Vector ? func.(d["new_value"]) : func(d["new_value"])
        else
            missing
        end
        old_value = if haskey(d, "old_value")
            d["old_value"] isa Vector ? func.(d["old_value"]) : func(d["old_value"])
        else
            missing
        end

        AuditLogChange{T, U}(new_value, old_value, d["key"], U)
    else
        AuditLogChange{Any, Any}(
            get(d, "new_value", missing),
            get(d, "old_value", missing),
            d["key"],
            Any,
        )
    end
end

function JSON.lower(x::AuditLogChange)
    d = Dict()
    if !ismissing(x.new_value)
        d["new_value"] = x.new_value
    end
    if !ismissing(x.old_value)
        d["old_value"] = x.new_value
    end
    d["key"] = x.key
    return d
end

"""
Optional information in an [`AuditLogEntry`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/audit-log#audit-log-entry-object-optional-audit-entry-info).
"""
struct AuditLogOptions
    delete_member_days::Union{Int, Missing}
    members_removed::Union{Int, Missing}
    channel_id::Union{Snowflake, Missing}
    count::Union{Int, Missing}
    id::Union{Snowflake, Missing}
    type::Union{OverwriteType, Missing}
    role_name::Union{String, Missing}
end
@boilerplate AuditLogOptions :docs :merge

function AuditLogOptions(d::Dict{String, Any})
    return AuditLogOptions(
        haskey(d, "delete_member_days") ? parse(Int, d["delete_member_days"]) : missing,
        haskey(d, "members_removed") ? parse(Int, d["members_removed"]) : missing,
        haskey(d, "channel_id") ? snowflake(d["channel_id"]) : missing,
        haskey(d, "count") ? parse(Int, d["count"]) : missing,
        haskey(d, "id") ? snowflake(d["id"]) : missing,
        haskey(d, "type") ? OverwriteType(d["type"]) : missing,
        get(d, "role_name", missing),
    )
end

function JSON.lower(x::AuditLogOptions)
    d = Dict()
    if !ismissing(x.delete_member_days)
        d["delete_member_days"] = string(d.delete_member_days)
    end
    if !ismissing(x.members_removed)
        d["members_removed"] = string(d.members_removed)
    end
    if !ismissing(x.channel_id)
        d["channel_id"] = string(d.members_removed)
    end
    if !ismissing(x.count)
        d["count"] = string(x.count)
    end
    if !ismissing(x.id)
        d["id"] = string(x.id)
    end
    if !ismissing(x.type)
        d["type"] = string(x.type)
    end
    if !ismissing(x.role_name)
        d["role_name"] = x.role_name
    end
    return d
end

"""
An entry in an [`AuditLog`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/audit-log#audit-log-entry-object).
"""
struct AuditLogEntry
    target_id::Union{Snowflake, Nothing}
    changes::Union{Vector{AuditLogChange}, Missing}
    user_id::Snowflake
    id::Snowflake
    action_type::ActionType
    options::Union{AuditLogOptions, Missing}
    reason::Union{String, Missing}
end
@boilerplate AuditLogEntry :dict :docs :lower :merge

"""
An audit log.
More details [here](https://discordapp.com/developers/docs/resources/audit-log#audit-log-object).
"""
struct AuditLog
    webhooks::Vector{Webhook}
    users::Vector{User}
    audit_log_entries::Vector{AuditLogEntry}
end
@boilerplate AuditLog :dict :docs :lower :merge
