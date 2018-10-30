export edit_integration,
    sync_integration,
    delete_integration

"""
    edit_integration(
        c::Client,
        guild::Union{AbstractGuild, Integer},
        integration::Union{Integration, Integer};
        params...,
    ) -> Response{Integration}

Modify an [`Integration`](@ref) in an [`AbstractGuild`](@ref).

# Keywords
- `expire_behavior::Integer`: The behavior when an integration subscription lapses.
- `expire_grace_period::Integer`: Period (in seconds) where the integration will ignore
  lapsed subscriptions.
- `enable_emoticons::Bool`: Whether emoticons should be synced for this integration (Twitch
  only currently).
"""
function edit_integration(c::Client, guild::Integer, integration::Integer; params...)
    return Response{Integration}(
        c,
        :PATCH,
        "/guilds/$guild/integrations/$integration";
        body=params,
    )
end

function edit_integration(c::Client, g::AbstractGuild, i::Integration; params...)
    return edit_integration(c, g.id, i.id; params...)
end

function edit_integration(c::Client, guild::Integer, i::Integration; params...)
    return edit_integration(c, guild, i.id; params...)
end

function edit_integration(c::Client, g::AbstractGuild, integration::Integer; params...)
    return edit_integration(c, g.id, integration; params...)
end

"""
    sync_integration(
        c::Client,
        guild::Union{Guild, Integer},
        integration::Union{Integration, Integer},
    ) -> Response

Sync an [`Integration`](@ref) in an `AbstractGuild`.
"""
function sync_integration(c::Client, guild::Integer, integration::Integer)
    return Response(c, :POST, "/guilds/$guild/integrations/$integration/sync")
end

function sync_integration(c::Client, g::AbstractGuild, i::Integration)
    return sync_integration(c, g.id, i.id)
end

function sync_integration(c::Client, guild::Integer, i::Integration)
    return sync_integration(c, guild, i.id)
end

function sync_integration(c::Client, g::AbstractGuild, integration::Integer)
    return sync_integration(c, g.id, Integration)
end

"""
    delete_integration(
        c::Client,
        guild::Union{AbstractGuild, Integer},
        integration::Union{Integration, Integer},
    ) -> Response

Delete an [`Integration`](@ref) in an [`AbstractGuild`](@ref).
"""
function delete_integration(c::Client, guild::Integer, integration::Integer)
    return Response(c, :DELETE, "/guilds/$guild/integrations/$integration")
end

function delete_integration(c::Client, g::AbstractGuild, i::Integration)
    return delete_integration(c, g.id, i.id)
end

function delete_integration(c::Client, guild::Integer, i::Integration)
    return delete_integration(c, guild, i.id)
end

function delete_integration(c::Client, g::AbstractGuild, integration::Integer)
    return delete_integration(c, g.id, Integration)
end
