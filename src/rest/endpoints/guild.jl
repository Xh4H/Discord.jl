export create_guild,
    get_guild,
    modify_guild,
    delete_guild,
    get_guild_channels,
    create_guild_channel,
    modify_guild_channel_positions,
    get_guild_member,
    list_guild_members,
    add_guild_member,
    modify_guild_member,
    modify_current_user_nick,
    add_guild_member_role,
    remove_guild_member_role,
    remove_guild_member,
    get_guild_bans,
    get_guild_ban,
    create_guild_ban,
    remove_guild_ban,
    get_guild_roles,
    create_guild_role,
    modify_guild_role_positions,
    modify_guild_role,
    delete_guild_role,
    get_guild_prune_count,
    begin_guild_prune,
    get_guild_voice_regions,
    get_guild_invites,
    get_guild_integrations,
    create_guild_integration,
    modify_guild_integration,
    delete_guild_integration,
    sync_guild_integration,
    get_guild_embed,
    modify_guild_embed,
    get_vanity_url,
    get_guild_widget_image

"""
    create_guild(c::Client; kwargs...) -> Guild

Create a [`Guild`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/guild#create-guild).
"""
create_guild(c::Client; kwargs...) = Response{Guild}(c, :POST, "/guilds"; body = kwargs)

"""
    get_guild(c::Client, guild::Integer) -> Guild

Get a [`Guild`](@ref).
"""
get_guild(c::Client, guild::Integer) = Response{Guild}(c, :GET, "/guilds/$guild")

"""
    modify_guild(c::Client, guild::Integer; kwargs...) -> Guild

Edit a [`Guild`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/guild#modify-guild).
"""
modify_guild(c::Client, guild::Integer; kwargs...) = Response{Guild}(c, :PATCH, "/guilds/$guild"; body = kwargs)

"""
    delete_guild(c::Client, guild::Integer)

Delete a [`Guild`](@ref).
"""
delete_guild(c::Client, guild::Integer) = Response(c, :DELETE, "/guilds/$guild")

"""
    get_guild_channels(c::Client, guild::Integer) -> Vector{DiscordChannel}

Get the [`DiscordChannel`](@ref)s in a [`Guild`](@ref).
"""
get_guild_channels(c::Client, guild::Integer) = Response{Vector{DiscordChannel}}(c, :GET, "/guilds/$guild/channels")

"""
    create_guild_channel(c::Client, guild::Integer; kwargs...) -> DiscordChannel

Create a [`DiscordChannel`](@ref) in a [`Guild`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/guild#create-guild-channel).
"""
create_guild_channel(c::Client, guild::Integer; kwargs...) = Response{DiscordChannel}(c, :POST, "/guilds/$guild/channels"; body = kwargs)

"""
    modify_guild_channel_positions(c::Client, guild::Integer, positions...)

Modify the positions of [`DiscordChannel`](@ref)s in a [`Guild`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/guild#modify-guild-channel-positions).
"""
modify_guild_channel_positions(c::Client, guild::Integer, positions...) = Response(c, :PATCH, "/guilds/$guild/channels"; body = positions)

"""
    get_guild_member(c::Client, guild::Integer, user::Integer) -> Member

Get a [`Member`](@ref) in a [`Guild`](@ref).
"""
get_guild_member(c::Client, guild::Integer, user::Integer) = Response{Member}(c, :GET, "/guilds/$guild/members/$user")

"""
    list_guild_members(c::Client, guild::Integer; kwargs...) -> Vector{Member}

Get a list of [`Member`](@ref)s in a [`Guild`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/guild#list-guild-members).
"""
list_guild_members(c::Client, guild::Integer; kwargs...) = Response{Vector{Member}}(c, :GET, "/guilds/$guild/members"; kwargs...)

"""
    add_guild_member(c::Client; kwargs...) -> Member

Add a [`User`](@ref) to a [`Guild`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/guild#add-guild-member).
"""
add_guild_member(c::Client, guild::Integer, user::Integer; kwargs...) = Response{Member}(c, :PUT, "/guilds/$guild/members/$user"; body = kwargs)

"""
    modify_guild__member(c::Client, guild::Integer, user::Integer; kwargs...)

Modify a [`Member`](@ref) in a [`Guild`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/guild#modify-guild-member).
"""
modify_guild_member(c::Client, guild::Integer, user::Integer; kwargs...) = Response(c, :PATCH, "/guilds/$guild/members/$user"; body = kwargs)

"""
    modify_current_user_nick(c::Client, guild::Intger; kwargs...) -> String

Modify the [`Client`](@ref) user's nickname in a [`Guild`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/guild#modify-current-user-nick).
"""
modify_current_user_nick(c::Client, guild::Integer; kwargs...) = Response{String}(c, :PATCH, "/guilds/$guild/members/@me/nick"; body = kwargs)

"""
    add_guild_member_role(c::Client, guild::Integer, user::Integer, role::Integer)

Add a [`Role`](@ref) to a [`Member`](@ref).
"""
add_guild_member_role(c::Client, guild::Integer, user::Integer, role::Integer) = Response(c, :PUT, "/guilds/$guild/members/$user/roles/$role")

"""
    remove_guild_member_role(c::Client, guild::Integer, user::Integer, role::Integer)

Remove a [`Role`](@ref) from a [`Member`](@ref).
"""
remove_guild_member_role(c::Client, guild::Integer, user::Integer, role::Integer) = Response(c, :DELETE, "/guilds/$guild/members/$user/roles/$role")

"""
    remove_guild_member(c::Client, guild::Integer, user::Integer)

Kick a [`Member`](@ref) from a [`Guild`](@ref).
"""
remove_guild_member(c::Client, guild::Integer, user::Integer) = Response(c, :DELETE, "/guilds/$guild/members/$user")

"""
    get_guild_bans(c::Client, guild::Integer) -> Vector{Ban}

Get a list of [`Ban`](@ref)s in a [`Guild`](@ref).
"""
get_guild_bans(c::Client, guild::Integer) = Response{Vector{Ban}}(c, :GET, "/guilds/$guild/bans")

"""
    get_ban(c::Client, guild::Integer,  user::Integer) -> Ban

Get a [`Ban`](@ref) in a [`Guild`](@ref).
"""
get_guild_ban(c::Client, guild::Integer, user::Integer) = Response{Ban}(c, :GET, "/guilds/$guild/bans/$user")

"""
    create_guild_ban(c::Client, guild::Integer, user::Integer; kwargs...)

Ban a [`Member`](@ref) from a [`Guild`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/guild#create-guild-ban).
"""
create_guild_ban(c::Client, guild::Integer, user::Integer; kwargs...) = Response(c, :PUT, "/guilds/$guild/bans/$user"; kwargs...)

"""
    remove_guild_ban(c::Client, guild::Integer, user::Integer)

Unban a [`User`](@ref) from a [`Guild`](@ref).
"""
remove_guild_ban(c::Client, guild::Integer, user::Integer) = Response(c, :DELETE, "/guilds/$guild/bans/$user")

"""
    get_guild_roles(c::Client, guild::Integer) -> Vector{Role}

Get a [`Guild`](@ref)'s [`Role`](@ref)s.
"""
get_guild_roles(c::Client, guild::Integer) = Response{Vector{Role}}(c, :GET, "/guilds/$guild/roles")

"""
    create_guild_role(c::Client, guild::Integer; kwargs) -> Role

Create a [`Role`](@ref) in a [`Guild`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/guild#create-guild-role).
"""
create_guild_role(c::Client, guild::Integer; kwargs...) = Response{Role}(c, :POST, "/guilds/$guild/roles"; body = kwargs)

"""
    modify_guild_role_positions(c::Client, guild::Integer, positions...) -> Vector{Role}

Modify the positions of [`Role`](@ref)s in a [`Guild`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/guild#modify-guild-role-positions).
"""
modify_guild_role_positions(c::Client, guild::Integer, positions...) = Response{Vector{Role}}(c, :PATCH, "/guilds/$guild/roles"; body = positions)

"""
    modify_guild_role(c::Client, guild::Integer, role::Integer; kwargs) -> Role

Modify a [`Role`](@ref) in a [`Guild`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/guild#modify-guild-role).
"""
modify_guild_role(c::Client, guild::Integer, role::Integer; kwargs...) = Response{Role}(c, :PATCH, "/guilds/$guild/roles/$role"; body = kwargs)

"""
    delete_guild_role(c::Client, guild::Integer, role::Integer)

Delete a [`Role`](@ref) from a [`Guild`](@ref).
"""
delete_guild_role(c::Client, guild::Integer, role::Integer) = Response(c, :DELETE, "/guilds/$guild/roles/$role")

"""
    get_guild_prune_count(c::Client, guild::Integer; kwargs...) -> Dict

Get the number of [`Member`](@ref)s that would be removed from a [`Guild`](@ref) in a prune.
More details [here](https://discordapp.com/developers/docs/resources/guild#get-guild-prune-count).
"""
get_guild_prune_count(c::Client, guild::Integer; kwargs...) = Response{Dict}(c, :GET, "/guilds/$guild/prune"; kwargs...)

"""
    begin_guild_prune(c::Client, guild::Integer; kwargs...) -> Dict

Begin pruning [`Member`](@ref)s from a [`Guild`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/guild#begin-guild-prune).
"""
begin_guild_prune(c::Client, guild::Integer; kwargs...) = Response{Dict}(c, :POST, "/guilds/$guild/prune"; kwargs...)

"""
    get_guild_voice_regions(c::Client, guild::Integer) -> Vector{VoiceRegion}

Get a list of [`VoiceRegion`](@ref)s for the [`Guild`](@ref).
"""
get_guild_voice_regions(c::Client, guild::Integer) = Response{Vector{VoiceRegion}}(c, :GET, "/guilds/$guild/regions")

"""
    get_guild_invites(c::Client, guild::Integer) -> Vector{Invite}

Get a list of [`Invite`](@ref)s to a [`Guild`](@ref).
"""
get_guild_invites(c::Client, guild::Integer) = Response{Vector{Invite}}(c, :GET, "/guilds/$guild/invites")

"""
    get_guild_integrations(c::Client, guild::Integer) -> Vector{Integration}

Get a list of [`Integration`](@ref)s for a [`Guild`](@ref).
"""
get_guild_integrations(c::Client, guild::Integer) = Response{Vector{Integration}}(c, :GET, "/guilds/$guild/integrations")

"""
    create_guild_integration(c::Client, guild::Integer; kwargs...)

Create/attach an [`Integration`](@ref) to a [`Guild`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/guild#create-guild-integration).
"""
create_guild_integration(c::Client, guild::Integer; kwargs...) = Response{Integration}(c, :POST, "/guilds/$guild/integrations"; body = kwargs)

"""
    modify_guild_integration(c::Client, guild::Integer, integration::Integer; kwargs...)

Modify an [`Integration`](@ref) in a [`Guild`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/guild#modify-guild-integration).
"""
modify_guild_integration(
    c::Client,
    guild::Integer,
    integration::Integer;
    kwargs...,
) = Response(c, :PATCH, "/guilds/$guild/integrations/$integration"; body = kwargs)

"""
    delete_guild_integration(c::Client, guild::Integer, integration::Integer)

Delete an [`Integration`](@ref) from a [`Guild`](@ref).
"""
delete_guild_integration(c::Client, guild::Integer, integration::Integer) = Response(c, :DELETE, "/guilds/$guild/integrations/$integration")


"""
    sync_guild_integration(c::Client, guild::Integer, integration::Integer)

Sync an [`Integration`](@ref) in a [`Guild`](@ref).
"""
sync_guild_integration(c::Client, guild::Integer, integration::Integer) = Response(c, :POST, "/guilds/$guild/integrations/$integration/sync")

"""
    get_guild_embed(c::Client, guild::Integer) -> GuildEmbed

Get a [`Guild`](@ref)'s [`GuildEmbed`](@ref).
"""
get_guild_embed(c::Client, guild::Integer) = Response{GuildEmbed}(c, :GET, "/guilds/$guild/embed")

"""
    modify_guild_embed(c::Client, guild::Integer; kwargs...) -> GuildEmbed

Modify a [`Guild`](@ref)'s [`GuildEmbed`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/guild#modify-guild-embed).
"""
modify_guild_embed(c::Client, guild::Integer; kwargs...) = Response{GuildEmbed}(c, :PATCH, "/guilds/$guild/embed"; body = kwargs)

"""
    get_vanity_url(c::Client, guild::Integer) -> Invite

Get a [`Guild`](@ref)'s vanity URL, if it supports that feature.
"""
get_vanity_url(c::Client, guild::Integer) = Response{Invite}(c, :GET, "/guilds/$guild/vanity-url")

"""
    get_guild_widget_image(c::Client, guild::Integer; kwargs...) -> Vector{UInt8}

Get a [`Guild`](@ref)'s widget image in PNG format.
More details [here](https://discordapp.com/developers/docs/resources/guild#get-guild-widget-image).
"""
get_guild_widget_image(c::Client, guild::Integer; kwargs...) = Response{Vector{UInt8}}(c, :GET, "/guilds/$guild/widget.png"; kwargs...)
