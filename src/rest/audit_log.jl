"""
    get_guild_audit_log(c::Client, guild::Integer; kwargs...) -> Future{Response{AuditLog}}

Get an [`AuditLog`](@ref).

# Keywords
- `user_id::Integer`: Filter the log for a [`User`](@ref) ID.
- `action_type::Integer`: The type of audit log event.
- `before::Integer`: filter the log before a certain entry ID.
- `limit::Integer`: How many entries are returned (default 50, minimum 1, maximum 100).
"""
function get_guild_audit_log(c::Client, guild::Integer; kwargs...)
    return Response{AuditLog}(c, :GET, "/guilds/$guild/audit-logs"; kwargs...)
end
