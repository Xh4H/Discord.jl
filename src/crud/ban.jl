function create(::Type{Ban}, c::Client, g::AbstractGuild, u::User; kwargs...)
    return create_guild_ban(c, g.id, u.id; kwargs...)
end

function retrieve(::Type{Ban}, c::Client, g::AbstractGuild, u::User)
    return get_guild_ban(c, g.id, u.id)
end

function delete(c::Client, b::Ban, g::AbstractGuild)
    return remove_guild_ban(c, g.id, b.user.id)
end
