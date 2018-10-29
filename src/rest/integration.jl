export edit_integration,
    sync_integration,
    delete_integration

"""
    edit_integration(
        c::Client,
        guild::Union{AbstractGuild, Integer},
        integration::Union{Integration, Integer};
        params...
    ) -> Response{Integration}

Modify an [`Integration`](@ref) in an [`AbstractGuild`](@ref).

# Keywords
- `expire_behavior::Int`: The behavior when an integration subscription lapses.
- `expire_grace_period::Int`: Period (in seconds) where the integration will ignore
  lapsed subscriptions.
- `enable_emoticons::Bool`: Whether emoticons should be synced for this integration (Twitch
   only currently).
"""
function edit_integration(c::Client, guild::Int, integration::Int; params...)
    return Response{Integration}(
        c,
        :PATCH,
        "/guilds/$guild/integrations/$integration";
        body=params
    )
end

function edit_integration(
    c::Client,
    guild::AbstractGuild,
    integration::Integration;
    params...
)
    return edit_integration(c, guild.id, integration.id; params...)
end

function edit_integration(c::Client, guild::Int, integration::Integration; params...)
    return edit_integration(c, guild, integration.id; params...)
end

function edit_integration(
    c::Client,
    guild::AbstractGuild,
    integration::Int;
    params...
)
    return edit_integration(c, guild.id, integration; params...)
end

"""
    sync_integration(
        c::Client,
        guild::Union{Guild, Integer},
        integration::Union{Integration, Integer}
    ) -> Response

Sync an [`Integration`](@ref) in an `AbstractGuild`.
"""
function sync_integration(c::Client, guild::Int, integration::Int)
    return Response(c, :POST, "/guilds/$guild/integrations/$integration/sync")
end

function sync_integration(c::Client, guild::AbstractGuild, integration::Integration)
    return sync_integration(c, guild.id, integration.id)
end

function sync_integration(c::Client, guild::Int, integration::Integration)
    return sync_integration(c, guild, integration.id)
end

function sync_integration(c::Client, guild::AbstractGuild, integration::Int)
    return sync_integration(c, guild.id, integration)
end

"""
    delete_integration(
        c::Client,
        guild::Union{AbstractGuild, Integer},
        integration::Union{Integration, Integer}
    ) -> Response

Delete an [`Integration`](@ref) in an [`AbstractGuild`](@ref).
"""
function delete_integration(c::Client, guild::Int, integration::Int)
    return Response(c, :DELETE, "/guilds/$guild/integrations/$integration")
end

function delete_integration(c::Client, guild::AbstractGuild, integration::Integration)
    return delete_integration(c, guild.id, integration.id)
end

function delete_integration(c::Client, guild::Int, integration::Integration)
    return delete_integration(c, guild, integration.id)
end

function delete_integration(c::Client, guild::AbstractGuild, integration::Int)
    return delete_integration(c, guild.id, integration)
end
