get(::Type{DiscordChannel}, c::Client, channel::Snowflake) = get_channel(c, channel)
function get(::Type{DiscordChannel}, c::Client, channel::Integer)
    return get(DiscordChannel, c, snowflake(channel))
end

create(::Type{DiscordChannel}, c::Client; kwargs...) = create_guild_channel(c; kwargs...)
edit(c::Client, ch::DiscordChannel; kwargs...) = modify_channel(c, ch.id; kwargs...)
delete(c::Client, ch::DiscordChannel) = delete_channel(c, ch.id)
