function create(::Type{DiscordChannel}, c::Client, g::AbstractGuild; kwargs...)
    return create_guild_channel(c, g.id; kwargs...)
end

retrieve(::Type{DiscordChannel}, c::Client, channel::Integer) = get_channel(c, channel)
update(c::Client, ch::DiscordChannel; kwargs...) = modify_channel(c, ch.id; kwargs...)
delete(c::Client, ch::DiscordChannel) = delete_channel(c, ch.id)
