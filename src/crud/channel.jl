function create(::Type{DiscordChannel}, c::Client, g::AbstractGuild; kwargs...)
    return create_guild_channel(c, g.id; kwargs...)
end
function create(::Type{DiscordChannel}, c::Client; kwargs...)
    return if haskey(kwargs, :recipient_id)
        create_dm(c; kwargs...)
    else
        create_group_dm(c; kwargs...)
    end
end

retrieve(::Type{DiscordChannel}, c::Client, channel::Integer) = get_channel(c, channel)
retrieve(::Type{DiscordChannel}, c::Client, g::AbstractGuild) = get_guild_channels(c, g.id)
retrieve(::Type{DiscordChannel}, c::Client) = get_user_dms(c)

update(c::Client, ch::DiscordChannel; kwargs...) = modify_channel(c, ch.id; kwargs...)

delete(c::Client, ch::DiscordChannel) = delete_channel(c, ch.id)
