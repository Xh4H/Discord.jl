retrieve(c::Client, ::Type{GuildEmbed}, g::AbstractGuild) = get_guild_embed(c, g.id)

update(c::Client, ::GuildEmbed, g::AbstractGuild; kwargs...) = modify_guild_embed(c, g.id; kwargs...)
