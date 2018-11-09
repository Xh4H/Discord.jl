function update(c::Client, o::Overwrite, ch::DiscordChannel; kwargs...)
    return edit_channel_permissions(c, ch.id, o.id; kwargs..., type=o.type)
end

function delete(c::Client, o::Overwrite, ch::DiscordChannel)
    return delete_channel_permission(c, ch.id, o.id)
end
