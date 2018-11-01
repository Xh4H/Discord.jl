export AuditLog

const AUDIT_LOG_CHANGE_TYPES = Dict(
    "name" => (String, Guild),
    "icon_hash" => (String, Guild) ,
    "splash_hash" => (String, Guild),
    "owner_id" => (Snowflake, Guild),
    "mentionable" => (Bool, Role),
    "permissions" => (Int, Role),
    # TODO
)

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
        AuditLogChange{T, U}(
            haskey(d, "new_value") ? T(d["new_value"]) : missing,
            haskey(d, "old_value") ? T(d["old_value"]) : missing,
            d["key"],
            U,
        )
    else
        AuditLogChange{Any, Any}(
            get(d, "new_value", missing),
            get(d, "old_value", missing),
            d["key"],
            Any,
        )
    end
end

function JSON.lower(alc::AuditLogChange)
    d = Dict()
    if !ismissing(alc.new_value)
        d["new_value"] = alc.new_value
    end
    if !ismissing(alc.old_value)
        d["old_value"] = alc.new_value
    end
    d["key"] = alc.key
    return d
end

# TODO: merge method?

"""
Optional information in an [`AuditLogEntry`](@ref).
"""
struct AuditLogOptions
    # TODO: We should probably parse/lower this manually.
    delete_member_days::Union{String, Missing}  # TODO: Int?
    members_removed::Union{String, Missing}  # TODO: Int?
    channel_id::Union{Snowflake, Missing}
    count::Union{String, Missing}  # TODO: Int?
    id::Union{Snowflake, Missing}
    type::Union{String, Missing}  # TODO: Enum?
    role_name::Union{String, Missing}
end
@boilerplate AuditLogOptions :dict :docs :lower :merge

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
