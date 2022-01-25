create(c::Client, ::Type{Role}, g::AbstractGuild; kwargs...) = create_guild_role(c, g.id; kwargs...)

retrieve(c::Client, ::Type{Role}, g::AbstractGuild) = get_guild_roles(c, g.id)

update(c::Client, r::Role, g::AbstractGuild; kwargs...) = modify_guild_role(c, g.id, r.id; kwargs...)

delete(c::Client, r::Role, g::AbstractGuild) = delete_guild_role(c, g.id, r.id)
