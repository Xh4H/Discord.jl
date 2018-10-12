export modify_integration,
        sync_integration,
        delete_integration

"""
    modify_integration(c::Client, guild::Union{Guild, Integer}, integration::Union{Integration, Integer}; params...) -> Response{Integration}

Modify an [`Integration`](@ref) in the given guild.

# Keywords
- `expire_behavior::Integer`: The behavior when an integration subscription lapses.
- `expire_grace_period::Integer`: Period (in seconds) where the integration will ignore lapsed subscriptions.
- `enable_emoticons::Bool`: Whether emoticons should be synced for this integration (twitch only currently).
"""
function modify_integration(c::Client, guild::Integer, integration::Integer; params...)
    return Response{Integration}(c, :PATCH, "/guilds/$guild/integrations/$integration"; body=params)
end

modify_integration(c::Client, guild::Guild, integration::Integration; params...) = modify_integration(c, guild.id, integration.id; params...)
modify_integration(c::Client, guild::Integer, integration::Integration; params...) = modify_integration(c, guild, integration.id; params...)
modify_integration(c::Client, guild::Guild, integration::Integer; params...) = modify_integration(c, guild.id, integration; params...)

"""
    sync_integration(c::Client, guild::Union{Guild, Integer}, integration::Union{Integration, Integer}) -> Response{Nothing}

Sync an [`Integration`](@ref) in the given guild.
"""
function sync_integration(c::Client, guild::Integer, integration::Integer)
    return Response{Nothing}(c, :POST, "/guilds/$guild/integrations/$integration/sync")
end

sync_integration(c::Client, guild::Guild, integration::Integration) = sync_integration(c, guild.id, integration.id)
sync_integration(c::Client, guild::Integer, integration::Integration) = sync_integration(c, guild, integration.id)
sync_integration(c::Client, guild::Guild, integration::Integer) = sync_integration(c, guild.id, integration)

"""
    delete_integration(c::Client, guild::Union{Guild, Integer}, integration::Union{Integration, Integer}) -> Response{Nothing}

Delete an [`Integration`](@ref) in the given guild.
"""
function delete_integration(c::Client, guild::Integer, integration::Integer)
    return Response{Nothing}(c, :DELETE, "/guilds/$guild/integrations/$integration")
end

delete_integration(c::Client, guild::Guild, integration::Integration) = delete_integration(c, guild.id, integration.id)
delete_integration(c::Client, guild::Integer, integration::Integration) = delete_integration(c, guild, integration.id)
delete_integration(c::Client, guild::Guild, integration::Integer) = delete_integration(c, guild.id, integration)
