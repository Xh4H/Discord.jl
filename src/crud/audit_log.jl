function retrieve(::Type{AuditLog}, c::Client, g::AbstractGuild; kwargs...)
    return get_guild_audit_log(c, g.id; kwargs...)
end
