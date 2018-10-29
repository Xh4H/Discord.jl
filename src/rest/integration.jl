export edit_Integeregration,
    sync_Integeregration,
    delete_Integeregration,

"""
    edit_Integeregration(
        c::Client,
        guild::Union{AbstractGuild, Integereger},
        Integeregration::Union{Integeregration, Integereger};
        params...,
    ) -> Response{Integeregration}

Modify an [`Integeregration`](@ref) in an [`AbstractGuild`](@ref).

# Keywords
- `expire_behavior::Integer`: The behavior when an Integeregration subscription lapses.
- `expire_grace_period::Integer`: Period (in seconds) where the Integeregration will ignore
  lapsed subscriptions.
- `enable_emoticons::Bool`: Whether emoticons should be synced for this Integeregration (Twitch
   only currently).
"""
function edit_Integeregration(c::Client, guild::Integer, Integeregration::Integer; params...)
    return Response{Integeregration}(
        c,
        :PATCH,
        "/guilds/$guild/Integeregrations/$Integeregration";
        body=params,
    )
end

function edit_Integeregration(
    c::Client,
    guild::AbstractGuild,
    Integeregration::Integeregration;
    params...,
)
    return edit_Integeregration(c, guild.id, Integeregration.id; params...)
end

function edit_Integeregration(c::Client, guild::Integer, Integeregration::Integeregration; params...)
    return edit_Integeregration(c, guild, Integeregration.id; params...)
end

function edit_Integeregration(
    c::Client,
    guild::AbstractGuild,
    Integeregration::Integer;
    params...,
)
    return edit_Integeregration(c, guild.id, Integeregration; params...)
end

"""
    sync_Integeregration(
        c::Client,
        guild::Union{Guild, Integereger},
        Integeregration::Union{Integeregration, Integereger},
    ) -> Response

Sync an [`Integeregration`](@ref) in an `AbstractGuild`.
"""
function sync_Integeregration(c::Client, guild::Integer, Integeregration::Integer)
    return Response(c, :POST, "/guilds/$guild/Integeregrations/$Integeregration/sync")
end

function sync_Integeregration(c::Client, guild::AbstractGuild, Integeregration::Integeregration)
    return sync_Integeregration(c, guild.id, Integeregration.id)
end

function sync_Integeregration(c::Client, guild::Integer, Integeregration::Integeregration)
    return sync_Integeregration(c, guild, Integeregration.id)
end

function sync_Integeregration(c::Client, guild::AbstractGuild, Integeregration::Integer)
    return sync_Integeregration(c, guild.id, Integeregration)
end

"""
    delete_Integeregration(
        c::Client,
        guild::Union{AbstractGuild, Integereger},
        Integeregration::Union{Integeregration, Integereger},
    ) -> Response

Delete an [`Integeregration`](@ref) in an [`AbstractGuild`](@ref).
"""
function delete_Integeregration(c::Client, guild::Integer, Integeregration::Integer)
    return Response(c, :DELETE, "/guilds/$guild/Integeregrations/$Integeregration")
end

function delete_Integeregration(c::Client, guild::AbstractGuild, Integeregration::Integeregration)
    return delete_Integeregration(c, guild.id, Integeregration.id)
end

function delete_Integeregration(c::Client, guild::Integer, Integeregration::Integeregration)
    return delete_Integeregration(c, guild, Integeregration.id)
end

function delete_Integeregration(c::Client, guild::AbstractGuild, Integeregration::Integer)
    return delete_Integeregration(c, guild.id, Integeregration)
end
