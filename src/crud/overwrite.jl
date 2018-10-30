function edit(c::Client, ch::DiscordChannel, o::Overwrite; kwargs...)
    return edit_channel_permissions(c, ch.id, o.id; kwargs...)
end

function delete(c::Client, ch::DiscordChannel, o::Overwrite)
    return delete_channel_permission(c, ch.id, o.id)
end
