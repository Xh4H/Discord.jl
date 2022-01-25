create(c::Client, ::Type{Invite}, ch::DiscordChannel; kwargs...) = create_channel_invite(c, ch.id; kwargs...)

retrieve(c::Client, ::Type{Invite}, g::AbstractGuild) = get_guild_invites(c, g.id)
retrieve(c::Client, ::Type{Invite}, ch::DiscordChannel) = get_channel_invites(c, ch.id)
retrieve(c::Client, ::Type{Invite}, invite::AbstractString; kwargs...) = get_invite(c, invite; kwargs...)

delete(c::Client, i::Invite) = delete_invite(c, i.code)
