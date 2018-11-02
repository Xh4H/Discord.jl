function create(::Type{Invite}, c::Client, ch::DiscordChannel; kwargs...)
    return create_channel_invite(c, ch.id; kwargs...)
end

retrieve(::Type{Invite}, c::Client, g::AbstractGuild) = get_guild_invites(c, g.id)
retrieve(::Type{Invite}, c::Client, ch::DiscordChannel) = get_channel_invites(c, ch.id)
function retrieve(::Type{Invite}, c::Client, invite::AbstractString; kwargs...)
    return get_invite(c, invite; kwargs...)
end

delete(c::Client, i::Invite) = delete_invite(c, i.code)
