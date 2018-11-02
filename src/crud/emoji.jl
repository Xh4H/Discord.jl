function create(c::Client, ::Type{Emoji}, g::AbstractGuild; kwargs...)
    return create_guild_emoji(c, g.id; kwargs...)
end

function retrieve(c::Client, ::Type{Emoji}, g::AbstractGuild, e::Emoji)
    return get_guild_emoji(c, g.id, e.id)
end
function retrieve(c::Client, ::Type{Emoji}, g::AbstractGuild)
    return list_guild_emojis(c, g.id)
end

function update(c::Client, g::AbstractGuild, e::Emoji; kwargs...)
    return modify_guild_emoji(c, g.id, e.id; kwargs...)
end

function delete(c::Client, g::AbstractGuild, e::Emoji)
    return delete_guild_emoji(c, g.id, e.id)
end
