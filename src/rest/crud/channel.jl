function create(c::Client, ::Type{DiscordChannel}, g::AbstractGuild; kwargs...)
    return create_guild_channel(c, g.id; kwargs...)
end
function create(c::Client, ::Type{DiscordChannel}, u::User; kwargs...)
    return create_dm(c; kwargs..., recipient_id=u.id)
end

retrieve(c::Client, ::Type{DiscordChannel}, channel::Integer) = get_channel(c, channel)
retrieve(c::Client, ::Type{DiscordChannel}, g::AbstractGuild) = get_guild_channels(c, g.id)

update(c::Client, ch::DiscordChannel; kwargs...) = modify_channel(c, ch.id; kwargs...)

delete(c::Client, ch::DiscordChannel) = delete_channel(c, ch.id)
