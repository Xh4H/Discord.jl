function retrieve(::Type{Vector{Emoji}}, c::Client, g::AbstractGuild)
    return list_guild_emojis(c, g.id)
end
function retrieve(::Type{Emoji}, c::Client, g::AbstractGuild, e::Emoji)
    return get_guild_emoji(c, g.id, e.id)
end

function create(::Type{Emoji}, c::Client, g::AbstractGuild; kwargs...)
    return create_guild_emoji(c, g.id; kwargs...)
end

function edit(c::Client, g::AbstractGuild, e::Emoji; kwargs...)
    return modify_guild_emoji(c, g.id, e.id; kwargs...)
end

function delete(c::Client, g::AbstractGuild, e::Emoji)
    return delete_guild_emoji(c, g.id, e.id)
end
