function create(c::Client, ::Type{Overwrite}, ch::DiscordChannel, r::Role; kwargs...)
    return edit_channel_permissions(c, ch.id, r.id; kwargs..., type=OT_ROLE)
end
function create(c::Client, ::Type{Overwrite}, ch::DiscordChannel, u::User; kwargs...)
    return edit_channel_permissions(c, ch.id, u.id; kwargs..., type=OT_MEMBER)
end

function update(c::Client, o::Overwrite, ch::DiscordChannel; kwargs...)
    return edit_channel_permissions(c, ch.id, o.id; kwargs..., type=o.type)
end

function delete(c::Client, o::Overwrite, ch::DiscordChannel)
    return delete_channel_permission(c, ch.id, o.id)
end
