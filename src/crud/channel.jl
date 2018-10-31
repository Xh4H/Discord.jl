retrieve(::Type{DiscordChannel}, c::Client, channel::Snowflake) = get_channel(c, channel)
function retrieve(::Type{DiscordChannel}, c::Client, channel::Integer)
    return retrieve(DiscordChannel, c, snowflake(channel))
end

function create(::Type{DiscordChannel}, c::Client, g::AbstractGuild; kwargs...)
    return create_guild_channel(c, g.id; kwargs...)
end

edit(c::Client, ch::DiscordChannel; kwargs...) = modify_channel(c, ch.id; kwargs...)
delete(c::Client, ch::DiscordChannel) = delete_channel(c, ch.id)
