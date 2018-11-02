function create(c::Client, ::Type{Member}, g::AbstractGuild, u::User; kwargs...)
    return add_guild_member(c, g.id, u.id; kwargs...)
end

function retrieve(c::Client, ::Type{Member}, g::AbstractGuild, u::User)
    return get_guild_member(c, g.id, u.id)
end
function retrieve(c::Client, ::Type{Member}, g::AbstractGuild)
    return list_guild_members(c, g.id)
end

function update(c::Client, m::Member, g::AbstractGuild; kwargs...)
    return modify_guild_member(c, g.id, m.user.id; kwargs...)
end
function update(c::Client, m::Member, r::Role, g::AbstractGuild)
    return add_guild_member_role(c, g.id, u.id, r.id)
end

function delete(c::Client, m::Member, g::AbstractGuild)
    return remove_guild_member(c, g.id, m.user.id)
end
function delete(c::Client, m::Member, r::Role, g::AbstractGuild)
    return remove_guild_member_role(c, g.id, u.id, r.id)
end
