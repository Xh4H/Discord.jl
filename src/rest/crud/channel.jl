create(c::Client, ::Type{DiscordChannel}, g::AbstractGuild; kwargs...) = create_guild_channel(c, g.id; kwargs...)
create(c::Client, ::Type{DiscordChannel}, u::User; kwargs...) = create_dm(c; kwargs..., recipient_id = u.id)

retrieve(c::Client, ::Type{DiscordChannel}, channel::Integer) = get_channel(c, channel)
retrieve(c::Client, ::Type{DiscordChannel}, g::AbstractGuild) = get_guild_channels(c, g.id)

update(c::Client, ch::DiscordChannel; kwargs...) = modify_channel(c, ch.id; kwargs...)

delete(c::Client, ch::DiscordChannel) = delete_channel(c, ch.id)
