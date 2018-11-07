export get_guild_audit_log

"""
    get_guild_audit_log(c::Client, guild::Integer; kwargs...) -> AuditLog

Get a [`Guild`](@ref)'s [`AuditLog`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/audit-log#get-guild-audit-log).
"""
function get_guild_audit_log(c::Client, guild::Integer; kwargs...)
    return Response{AuditLog}(c, :GET, "/guilds/$guild/audit-logs"; kwargs...)
end
