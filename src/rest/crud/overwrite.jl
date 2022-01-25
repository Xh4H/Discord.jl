create(c::Client, ::Type{Overwrite}, ch::DiscordChannel, r::Role; kwargs...) = edit_channel_permissions(c, ch.id, r.id; kwargs..., type = OT_ROLE)
create(c::Client, ::Type{Overwrite}, ch::DiscordChannel, u::User; kwargs...) = edit_channel_permissions(c, ch.id, u.id; kwargs..., type = OT_MEMBER)

update(c::Client, o::Overwrite, ch::DiscordChannel; kwargs...) = edit_channel_permissions(c, ch.id, o.id; kwargs..., type = o.type)

delete(c::Client, o::Overwrite, ch::DiscordChannel) = delete_channel_permission(c, ch.id, o.id)
