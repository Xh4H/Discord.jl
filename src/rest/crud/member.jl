create(c::Client, ::Type{Member}, g::AbstractGuild, u::User; kwargs...) = add_guild_member(c, g.id, u.id; kwargs...)

retrieve(c::Client, ::Type{Member}, g::AbstractGuild, u::User) = get_guild_member(c, g.id, u.id)
retrieve(c::Client, ::Type{Member}, g::AbstractGuild) = list_guild_members(c, g.id)

update(c::Client, m::Member, g::AbstractGuild; kwargs...) = modify_guild_member(c, g.id, m.user.id; kwargs...)
update(c::Client, m::Member, r::Role, g::AbstractGuild) = add_guild_member_role(c, g.id, m.user.id, r.id)

delete(c::Client, m::Member, g::AbstractGuild) = remove_guild_member(c, g.id, m.user.id)
delete(c::Client, m::Member, r::Role, g::AbstractGuild) = remove_guild_member_role(c, g.id, m.user.id, r.id)
