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
- `expire_behavior::Integer`: The behavior when an Integration subscription lapses.
- `expire_grace_period::Integer`: Period (in seconds) where the Integration will ignore
  lapsed subscriptions.
- `enable_emoticons::Bool`: Whether emoticons should be synced for this Integration (Twitch
   only currently).
"""
function edit_integration(c::Client, guild::Integer, integration::Integer; params...)
    return Response{Integration}(
        c,
        :PATCH,
        "/guilds/$guild/Integrations/$Integration";
        body=params,
    )
end

function edit_integration(
    c::Client,
    guild::AbstractGuild,
    integration::Integration;
    params...,
)
    return edit_integration(c, guild.id, Integration.id; params...)
end

function edit_integration(c::Client, guild::Integer, integration::Integration; params...)
    return edit_integration(c, guild, Integration.id; params...)
end

function edit_integration(
    c::Client,
    guild::AbstractGuild,
    integration::Integer;
    params...,
)
    return edit_integration(c, guild.id, Integration; params...)
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
    return Response(c, :POST, "/guilds/$guild/Integrations/$Integration/sync")
end

function sync_integration(c::Client, guild::AbstractGuild, integration::Integration)
    return sync_integration(c, guild.id, Integration.id)
end

function sync_integration(c::Client, guild::Integer, integration::Integration)
    return sync_integration(c, guild, Integration.id)
end

function sync_integration(c::Client, guild::AbstractGuild, integration::Integer)
    return sync_integration(c, guild.id, Integration)
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
    return Response(c, :DELETE, "/guilds/$guild/Integrations/$Integration")
end

function delete_integration(c::Client, guild::AbstractGuild, integration::Integration)
    return delete_integration(c, guild.id, Integration.id)
end

function delete_integration(c::Client, guild::Integer, integration::Integration)
    return delete_integration(c, guild, Integration.id)
end

function delete_integration(c::Client, guild::AbstractGuild, integration::Integer)
    return delete_integration(c, guild.id, Integration)
end
