function retrieve(c::Client, ::Type{AuditLog}, g::AbstractGuild; kwargs...)
    return get_guild_audit_log(c, g.id; kwargs...)
end
