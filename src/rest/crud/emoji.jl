create(c::Client, ::Type{Emoji}, g::AbstractGuild; kwargs...) = create_guild_emoji(c, g.id; kwargs...)

retrieve(c::Client, ::Type{Emoji}, g::AbstractGuild, e::Emoji) = get_guild_emoji(c, g.id, e.id)
retrieve(c::Client, ::Type{Emoji}, g::AbstractGuild) = list_guild_emojis(c, g.id)

update(c::Client, e::Emoji, g::AbstractGuild; kwargs...) = modify_guild_emoji(c, g.id, e.id; kwargs...)

delete(c::Client, e::Emoji, g::AbstractGuild) = delete_guild_emoji(c, g.id, e.id)
