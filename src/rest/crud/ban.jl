create(c::Client, ::Type{Ban}, g::AbstractGuild, u::User; kwargs...) = create_guild_ban(c, g.id, u.id; kwargs...)

retrieve(c::Client, ::Type{Ban}, g::AbstractGuild, u::User) = get_guild_ban(c, g.id, u.id)
retrieve(c::Client, ::Type{Ban}, g::AbstractGuild) = get_guild_bans(c, g.id)

delete(c::Client, b::Ban, g::AbstractGuild) = remove_guild_ban(c, g.id, b.user.id)
