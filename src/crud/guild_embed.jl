retrieve(::Type{GuildEmbed}, c::Client, g::AbstractGuild) = get_guild_embed(c, g.id)

update(c::Client, g::AbstractGuild; kwargs...) = modify_guild_embed(c, g.id; kwargs...)
