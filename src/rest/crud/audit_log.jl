retrieve(c::Client, ::Type{AuditLog}, g::AbstractGuild; kwargs...) = get_guild_audit_log(c, g.id; kwargs...)
