create(c::Client, ::Type{Integration}, g::AbstractGuild; kwargs...) = create_guild_integration(c, g.id; kwargs...)

retrieve(c::Client, ::Type{Integration}, g::AbstractGuild) = get_guild_integrations(c, g.id)

update(c::Client, i::Integration, g::AbstractGuild; kwargs...) = modify_guild_integration(c, g.id, i.id; kwargs...)

delete(c::Client, i::Integration, g::AbstractGuild) = delete_guild_integration(c, g.id, i.id)
