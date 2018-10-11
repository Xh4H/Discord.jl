export modify_integration,
        sync_integration,
        delete_integration

"""
    modify_integration(c::Client, integration::Integer, guild::Integer, params...) -> Response{Integration}
    modify_integration(c::Client, integration::Integration, guild::Guild, params...) -> Response{Integration}
    modify_integration(c::Client, integration::Integration, guild::Integer, params...) -> Response{Integration}
    modify_integration(c::Client, integration::Integer, guild::Guild, params...) -> Response{Integration}

Modify an [`Integration`](@ref) in the given guild.

# Keywords
- `expire_behavior::Integer`: The behavior when an integration subscription lapses.
- `expire_grace_period::Integer`: Period (in seconds) where the integration will ignore lapsed subscriptions.
- `enable_emoticons::Bool`: Whether emoticons should be synced for this integration (twitch only currently).
"""
function modify_integration(c::Client, integration::Integer, guild::Integer, params...)
    return Response{Integration}(c, :PATCH, "/guilds/$guild/integrations/$integration"; body=params)
end

modify_integration(c::Client, integration::Integration, guild::Guild, params...) = modify_integration(c, integration.id, guild.id, params)
modify_integration(c::Client, integration::Integration, guild::Integer, params...) = modify_integration(c, integration.id, guild, params)
modify_integration(c::Client, integration::Integer, guild::Guild, params...) = modify_integration(c, integration, guild.id, params)

"""
    sync_integration(c::Client, integration::Integer, guild::Integer) -> Response{Nothing}
    sync_integration(c::Client, integration::Integration, guild::Guild) -> Response{Nothing}
    sync_integration(c::Client, integration::Integration, guild::Integer) -> Response{Nothing}
    sync_integration(c::Client, integration::Integer, guild::Guild) -> Response{Nothing}

Sync an [`Integration`](@ref) in the given guild.
"""
function sync_integration(c::Client, integration::Integer, guild::Integer)
    return Response{Nothing}(c, :POST, "/guilds/$guild/integrations/$integration/sync")
end

sync_integration(c::Client, integration::Integration, guild::Guild) = sync_integration(c, integration.id, guild.id)
sync_integration(c::Client, integration::Integration, guild::Integer) = sync_integration(c, integration.id, guild)
sync_integration(c::Client, integration::Integer, guild::Guild) = sync_integration(c, integration, guild.id)

"""
    delete_integration(c::Client, integration::Integer, guild::Integer) -> Response{Nothing}
    delete_integration(c::Client, integration::Integration, guild::Guild) -> Response{Nothing}
    delete_integration(c::Client, integration::Integration, guild::Integer) -> Response{Nothing}
    delete_integration(c::Client, integration::Integer, guild::Guild) -> Response{Nothing}

Delete an [`Integration`](@ref) in the given guild.
"""
function delete_integration(c::Client, integration::Integer, guild::Integer)
    return Response{Nothing}(c, :DELETE, "/guilds/$guild/integrations/$integration")
end

delete_integration(c::Client, integration::Integration, guild::Guild) = delete_integration(c, integration.id, guild.id)
delete_integration(c::Client, integration::Integration, guild::Integer) = delete_integration(c, integration.id, guild)
delete_integration(c::Client, integration::Integer, guild::Guild) = delete_integration(c, integration, guild.id)
