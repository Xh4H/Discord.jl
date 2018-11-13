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

AuditLogChange(d::Dict{Symbol, Any}) = AuditLogChange(; d...)
function AuditLogChange(; kwargs...)
    return if haskey(AUDIT_LOG_CHANGE_TYPES, kwargs[:key])
        T, U = AUDIT_LOG_CHANGE_TYPES[kwargs[:key]]
        func = if T === Any
            identity
        elseif T === Snowflake
            snowflake
        elseif T <: Vector
            eltype(T)
        else
            T
        end

        new_value = if haskey(kwargs, :new_value)
            if kwargs[:new_value] isa Vector
                func.(kwargs[:new_value])
            else
                func(kwargs[:new_value])
            end
        else
            missing
        end
        old_value = if haskey(kwargs, :old_value)
            if kwargs[:old_value] isa Vector
                func.(kwargs[:old_value])
            else
                func(kwargs[:old_value])
            end
        else
            missing
        end

        AuditLogChange{T, U}(new_value, old_value, kwargs[:key], U)
    else
        AuditLogChange{Any, Any}(
            get(kwargs, :new_value, missing),
            get(kwargs, :old_value, missing),
            kwargs[:key],
            Any,
        )
    end
end

function JSON.lower(x::AuditLogChange)
    d = Dict{Symbol, Any}()
    if !ismissing(x.new_value)
        d[:new_value] = x.new_value
    end
    if !ismissing(x.old_value)
        d[:old_value] = x.new_value
    end
    d[:key] = x.key
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

AuditLogOptions(d::Dict{Symbol, Any}) = AuditLogOptions(; d...)
function AuditLogOptions(; kwargs...)
    dmd = if haskey(kwargs, :delete_member_days)
        parse(Int, kwargs[:delete_member_days])
    else
        missing
    end
    return AuditLogOptions(
        dmd,
        haskey(kwargs, :members_removed) ? parse(Int, kwargs[:members_removed]) : missing,
        haskey(kwargs, :channel_id) ? snowflake(kwargs[:channel_id]) : missing,
        haskey(kwargs, :count) ? parse(Int, kwargs[:count]) : missing,
        haskey(kwargs, :id) ? snowflake(kwargs[:id]) : missing,
        haskey(kwargs, :type) ? OverwriteType(kwargs[:type]) : missing,
        get(kwargs, :role_name, missing),
    )
end

function JSON.lower(x::AuditLogOptions)
    d = Dict{Symbol, Any}()
    if !ismissing(x.delete_member_days)
        d[:delete_member_days] = string(d.delete_member_days)
    end
    ismissing(x.members_removed) || (d[:members_removed] = string(d.members_removed))
    ismissing(x.channel_id) || (d[:channel_id] = string(d.members_removed))
    ismissing(x.count) || (d[:count] = string(x.count))
    ismissing(x.id) || (d[:id] = string(x.id))
    ismissing(x.type) || (d[:type] = string(x.type))
    ismissing(x.role_name) || (d[:role_name] = x.role_name)
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
@boilerplate AuditLogEntry :constructors :docs :lower :merge

"""
An audit log.
More details [here](https://discordapp.com/developers/docs/resources/audit-log#audit-log-object).
"""
struct AuditLog
    webhooks::Vector{Webhook}
    users::Vector{User}
    audit_log_entries::Vector{AuditLogEntry}
end
@boilerplate AuditLog :constructors :docs :lower :merge
