function create(c::Client, ::Type{Role}, g::AbstractGuild; kwargs...)
    return create_guild_role(c, g.id; kwargs...)
end

retrieve(c::Client, ::Type{Role}, g::AbstractGuild) = get_guild_roles(c, g.id)

function update(c::Client, r::Role, g::AbstractGuild; kwargs...)
    return modify_guild_role(c, g.id, r.id; kwargs...)
end

delete(c::Client, r::Role, g::AbstractGuild) = delete_guild_role(c, g.id, r.id)
