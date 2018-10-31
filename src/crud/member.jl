function retrieve(::Type{Member}, c::Client, g::AbstractGuild, u::User)
    return get_guild_member(c, g.id, u.id)
end

function create(::Type{Member}, c::Client, g::AbstractGuild, u::User; kwargs...)
    return add_guild_member(c, g.id, u.id; kwargs...)
end

function update(c::Client, m::Member, g::AbstractGuild; kwargs...)
    return modify_guild_member(c, g.id, m.user.id; kwargs...)
end

function delete(c::Client, m::Member, g::AbstractGuild)
    return remove_guild_member(c, g.id, m.user.id)
end

function retrieve(::Type{Vector{Member}}, c::Client, g::AbstractGuild)
    return list_guild_members(c, g.id)
end
