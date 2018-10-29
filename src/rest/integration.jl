export edit_Integration,
    sync_Integration,
    delete_Integration

"""
    edit_Integration(
        c::Client,
        guild::Union{AbstractGuild, Integer},
        Integration::Union{Integration, Integer};
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
function edit_Integration(c::Client, guild::Integer, Integration::Integer; params...)
    return Response{Integration}(
        c,
        :PATCH,
        "/guilds/$guild/Integrations/$Integration";
        body=params,
    )
end

function edit_Integration(
    c::Client,
    guild::AbstractGuild,
    Integration::Integration;
    params...,
)
    return edit_Integration(c, guild.id, Integration.id; params...)
end

function edit_Integration(c::Client, guild::Integer, Integration::Integration; params...)
    return edit_Integration(c, guild, Integration.id; params...)
end

function edit_Integration(
    c::Client,
    guild::AbstractGuild,
    Integration::Integer;
    params...,
)
    return edit_Integration(c, guild.id, Integration; params...)
end

"""
    sync_Integration(
        c::Client,
        guild::Union{Guild, Integer},
        Integration::Union{Integration, Integer},
    ) -> Response

Sync an [`Integration`](@ref) in an `AbstractGuild`.
"""
function sync_Integration(c::Client, guild::Integer, Integration::Integer)
    return Response(c, :POST, "/guilds/$guild/Integrations/$Integration/sync")
end

function sync_Integration(c::Client, guild::AbstractGuild, Integration::Integration)
    return sync_Integration(c, guild.id, Integration.id)
end

function sync_Integration(c::Client, guild::Integer, Integration::Integration)
    return sync_Integration(c, guild, Integration.id)
end

function sync_Integration(c::Client, guild::AbstractGuild, Integration::Integer)
    return sync_Integration(c, guild.id, Integration)
end

"""
    delete_Integration(
        c::Client,
        guild::Union{AbstractGuild, Integer},
        Integration::Union{Integration, Integer},
    ) -> Response

Delete an [`Integration`](@ref) in an [`AbstractGuild`](@ref).
"""
function delete_Integration(c::Client, guild::Integer, Integration::Integer)
    return Response(c, :DELETE, "/guilds/$guild/Integrations/$Integration")
end

function delete_Integration(c::Client, guild::AbstractGuild, Integration::Integration)
    return delete_Integration(c, guild.id, Integration.id)
end

function delete_Integration(c::Client, guild::Integer, Integration::Integration)
    return delete_Integration(c, guild, Integration.id)
end

function delete_Integration(c::Client, guild::AbstractGuild, Integration::Integer)
    return delete_Integration(c, guild.id, Integration)
end
