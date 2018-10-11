export modify_integration,
        sync_integration,
        delete_integration

"""
    modify_integration(c::Client, integration::Integer, guild::Integer, params...) -> Response{Integration}

Modify an [`Integration`](@ref) in the given guild with the given parameters.

# Keywords
- `expire_behavior::Integer`: The behavior when an integration subscription lapses.
- `expire_grace_period::Integer`: Period (in seconds) where the integration will ignore lapsed subscriptions.
- `enable_emoticons::Bool`: Whether emoticons should be synced for this integration (twitch only currently).
"""
function modify_integration(c::Client, integration::Integer, guild::Integer, params...)
    return Response{Integration}(c, :PATCH, "/guilds/$guild/integrations/$integration"; body=params)
end

"""
    sync_integration(c::Client, integration::Integer, guild::Integer) -> Response{Nothing}

Sync an [`Integration`](@ref) in the given guild.
"""
function sync_integration(c::Client, integration::Integer, guild::Integer)
    return Response{Nothing}(c, :POST, "/guilds/$guild/integrations/$integration/sync")
end

"""
    delete_integration(c::Client, integration::Integer, guild::Integer) -> Response{Nothing}

Delete an [`Integration`](@ref) in the given guild.
"""
function delete_integration(c::Client, integration::Integer, guild::Integer)
    return Response{Nothing}(c, :DELETE, "/guilds/$guild/integrations/$integration")
end
