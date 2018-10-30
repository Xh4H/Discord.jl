function get(::Type{Vector{Invite}}, c::Client, ch::DiscordChannel)
    return get_channel_invites(c, ch.id)
end

function create(::Type{Invite}, c::Client, ch::DiscordChannel; kwargs...)
    return create_channel_invite(c, ch; kwargs...)
end
