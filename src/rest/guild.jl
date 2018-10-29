export create_guild,
        get_guild,
        edit_guild,
        delete_guild,
        leave_guild,
        create_role,
        edit_role_positions,
        get_roles,
        create_channel,
        add_member,
        get_member,
        list_members,
        get_prune,
        do_prune,
        get_bans,
        get_ban,
        unban,
        get_guild_invites,
        create_integration,
        get_integrations,
        get_guild_webhooks,
        get_regions,
        get_guild_regions,
        get_vanity_code

"""
    create_guild(c::Client; params...) -> Response{Guild}

Create a [`Guild`](@ref).

# Keywords
- `name::AbstractString`: Guild name (2-100 characters).
- `region::Snowflake`: Desired voice region ID.
- `icon::AbstractString`: Base64 128x128 jpeg image for the guild icon.
- `verification_level::Int`: Verification level.
- `default_message_notifications::Int`: Default message notification level.
- `explicit_content_filter::Int`: Explicit content filter level.
- `roles::Vector{Role}`: New guild roles.
- `channels::Vector{DiscordChannel}`: New guild channels.

More details [here](https://discordapp.com/developers/docs/resources/guild#create-guild).
"""
function create_guild(c::Client; params...)
    return Response{Guild}(c, :POST, "/guilds"; body=params)
end

"""
    get_guild(c::Client,
        guild::Union{AbstractGuild, Integer}
    ) -> Response{Guild}

Get a [`Guild`](@ref).
"""
function get_guild(c::Client, guild::Int)
    return if haskey(c.state.guilds, guild)
        Response{Guild}(c.state.guilds[guild])
    else
        Response{Guild}(c, :GET, "/guilds/$guild")
    end
end

get_guild(c::Client, guild::AbstractGuild) = get_guild(c, guild.id)

"""
    edit_guild(
        c::Client,
        guild::Union{AbstractGuild, Integer};
        params...
    ) -> Response{Guild}

Modify a [`Guild`](@ref).

# Keywords
- `name::AbstractString`: Guild name (2-100 characters).
- `region::Snowflake`: Desired voice region ID.
- `icon::AbstractString`: Base64 128x128 jpeg image for the guild icon.
- `verification_level::Int`: Verification level.
- `default_message_notifications::Int`: Default message notification level.
- `explicit_content_filter::Int`: Explicit content filter level.
- `afk_channel_id::Snowflake`: ID for afk channel.
- `afk_timeout::Int`: Afk timeout in seconds.
- `icon::AbstractString`: Base64 128x128 jpeg image for the guild icon.
- `owner_id::Snowflake`: User ID to transfer guild ownership to (must be owner).
- `splash::AbstractString`: Base64 128x128 jpeg image for the guild splash (VIP only).
- `system_channel_id::Snowflake`: The ID of the channel to which system messages are sent.

More details [here](https://discordapp.com/developers/docs/resources/guild#modify-guild).
"""
function edit_guild(c::Client, guild::Int; params...)
    return Response{Guild}(c, :PATCH, "/guilds/$guild"; body=params)
end

function edit_guild(c::Client, g::AbstractGuild; params...)
    return edit_guild(c, g.id; params...)
end

"""
    delete_guild(c::Client, guild::Union{AbstractGuild, Integer}) -> Response{Nothing}

Delete a [`Guild`](@ref).
"""
function delete_guild(c::Client, guild::Int)
    return Response{Nothing}(c, :DELETE, "/guilds/$guild")
end

delete_guild(c::Client, g::AbstractGuild) = delete_guild(c, g.id)

"""
    leave_guild(c::Client, guild::Union{AbstractGuild, Integer}) -> Response{Nothing}

Leave a [`Guild`](@ref).
"""
function leave_guild(c::Client, guild::Int)
    return Response{Nothing}(c, :DELETE, "/users/@me/guilds/$guild")
end

leave_guild(c::Client, g::AbstractGuild) = delete_guild(c, g.id)

"""
    create_role(c::Client,
        guild::Union{AbstractGuild, Integer};
        params...
    ) -> Response{Role}

Create a [`Role`](@ref).

# Keywords
- `name::AbstractString`: Role name.
- `permissions::Int`: Bitwise value of the enabled/disabled permissions.
- `color::Int`: RGB color value.
- `hoist::Bool`: Whether the role should be displayed separately in the sidebar.
- `mentionable::Bool`: Whether the role should be mentionable.
"""
function create_role(c::Client, guild::Int; params...)
    return Response{Role}(c, :POST, "/guilds/$guild/roles"; body=params)
end

create_role(c::Client, g::AbstractGuild; params...) = create_role(c, g.id; params...)

"""
    edit_role_positions(c::Client,
        guild::Union{AbstractGuild, Integer};
        params...
    ) -> Response{Vector{Role}}

Modify the positions of a set of [`Role`](@ref)s.

# Keywords
Must be a list with the keywords listed below.
- `id::Snowflake`: Role ID.
- `position::Int`: Position of the role.
"""
function edit_role_positions(c::Client, guild::Int; params...)
    return Response{Role}(c, :PATCH, "/guilds/$guild/roles"; body=params)
end

function edit_role_positions(c::Client, g::AbstractGuild; params...)
    return edit_role_positions(c, g.id; params...)
end

"""
    get_roles(c::Client, guild::Union{AbstractGuild, Integer}) -> Response{Vector{Role}}

Get the [`Role`](@ref)s.
"""
function get_roles(c::Client, guild::Int)
    return Response{Role}(c, :GET, "/guilds/$guild/roles")
end

get_roles(c::Client, g::AbstractGuild) = get_roles(c, g.id)

"""
    create_channel(c::Client; params...) -> Response{DiscordChannel}

Create a [`DiscordChannel`](@ref).

# Keywords
- `name::AbstractString`: Channel name (2-100 characters).
- `type::Int`: Channel type.
- `topic::AbstractString`: Channel topic (0-1024 characters).
- `bitrate::Int`: The bitrate (in bits) of the voice channel (voice only).
- `user_limit::Int`: The user limit of the voice channel (voice only).
- `rate_limit_per_user::Int`: Amount of seconds a user has to wait before
    sending another message (0-120).
- `permission_overwrites::Vector{Overwrite}`: The channel's permission overwrites.
- `nsfw::Bool`: Whether the channel is nsfw.

More details [here](https://discordapp.com/developers/docs/resources/guild#create-guild-channel).
"""
function create_channel(c::Client, guild::Int; params...)
    (haskey(params, :bitrate) || haskey(params, :user_limit)) &&
        haskey(c.state.channels, channel) &&
        params["type"] === CT_GUILD_VOICE &&
        throw(ArgumentError(
            "Bitrate and user limit can only be modified for voice channels",
        ))
    return Response{Guild}(c, :POST, "/guilds/$guild/channels"; body=params)
end

create_channel(c::Client, g::AbstractGuild; params...) = create_channel(c, g.id; params...)

"""
    add_member(c::Client; params...) -> Response{Member}

Add a [`User`](@ref) to a [`Guild`](@ref).

# Keywords
- `access_token::AbstractString`: Oath2 access token.
- `nick::AbstractString`: Value to set users nickname to.
- `roles::Vector{Snowflake}`: Array of role IDs the member is assigned.
- `mute::Bool`: Whether the user should be muted.
- `deaf::Bool`: Whether the user should be deafened.

More details [here](https://discordapp.com/developers/docs/resources/guild#add-guild-member).
"""
function add_member(c::Client, guild::Int, user::Int; params...)
    return Response{Member}(c, :PUT, "/guilds/$guild/members/$user"; body=params)
end

add_member(c::Client, g::AbstractGuild, u::User; params...) = add_member(c, g.id, u.id; params...)
add_member(c::Client, g::AbstractGuild, u::Int; params...) = add_member(c, g.id, u; params...)
add_member(c::Client, g::Int, u::User; params...) = add_member(c, g, u.id; params...)

"""
    get_member(c::Client,
        guild::Union{AbstractGuild, Integer},
        user::Union{User, Integer}
    ) -> Response{Member}

Get a [`Member`](@ref).
"""
function get_member(c::Client, guild::Int, user::Int)
    return if haskey(c.state.members, user)
        Response{Member}(c.state.members[user])
    else
        Response{Member}(c, :GET, "/guilds/$guild/members/$user")
    end
end

get_member(c::Client, g::AbstractGuild, u::User) = get_member(c, g.id, u.id)
get_member(c::Client, g::AbstractGuild, u::Int) = get_member(c, g.id, u)
get_member(c::Client, g::Int, u::User) = get_member(c, g, u.id)

"""
    list_members(c::Client
        guild::Union{AbstractGuild, Integer};
        params...
    ) -> Response{Vector{Member}}

Get the [`Member`](@ref)s from a [`Guild`](@ref).

# Query Params
- `limit::Int`: Max number of members to return (1-1000).
- `after::Snowflake`: The highest user ID in the previous page.

More details [here](https://discordapp.com/developers/docs/resources/guild#list-guild-members).
"""
function list_members(c::Client, guild::Int; params...)
    return Response{Member}(c, :GET, "/guilds/$guild/members"; params...)
end

list_members(c::Client, g::AbstractGuild; params...) = list_members(c, g.id; params...)

"""
    get_prune(c::Client
        guild::Union{AbstractGuild, Integer};
        params...
    ) -> Response{Integer}

Get the number of [`Member`](@ref)s that would be removed in a prune.

# Query Params
- `days::Int`: Number of days to count prune for (1 or more).

More details [here](https://discordapp.com/developers/docs/resources/guild#get-guild-prune-count).
"""
function get_prune(c::Client, guild::Int; params...)
    return Response{Integer}(c, :GET, "/guilds/$guild/prune"; params...)
end

get_prune(c::Client, g::AbstractGuild; params...) = get_prune(c, g.id; params...)

"""
    do_prune(c::Client
        guild::Union{AbstractGuild, Integer};
        params...
    ) -> Response{Integer}

Begin a prune.

# Query Params
- `days::Int`: Number of days to prune for (1 or more).

More details [here](https://discordapp.com/developers/docs/resources/guild#begin-guild-prune).
"""
function do_prune(c::Client, guild::Int; params...)
    return Response{Integer}(c, :POST, "/guilds/$guild/prune"; params...)
end

do_prune(c::Client, g::AbstractGuild; params...) = do_prune(c, g.id; params...)

"""
    get_bans(c::Client, guild::Union{AbstractGuild, Integer}) -> Response{Vector{Ban}}

Get the [`Ban`](@ref)s.
"""
function get_bans(c::Client, guild::Int)
    return Response{Ban}(c, :GET, "/guilds/$guild/bans")
end

get_bans(c::Client, g::AbstractGuild) = get_bans(c, g.id)

"""
    get_ban(c::Client,
        guild::Union{AbstractGuild, Integer},
        user::Union{User, Integer}
    ) -> Response{Ban}

Get a [`Ban`](@ref).
"""
function get_ban(c::Client, guild::Int, user::Int)
    return Response{Ban}(c, :GET, "/guilds/$guild/bans/$user")
end

get_ban(c::Client, g::AbstractGuild, u::User) = get_ban(c, g.id, u.id)
get_ban(c::Client, g::AbstractGuild, u::Int) = get_ban(c, g.id, u)
get_ban(c::Client, g::Int, u::User) = get_ban(c, g, u.id)

"""
    unban(c::Client,
        guild::Union{AbstractGuild, Integer},
        user::Union{Member, Integer}
    ) -> Response{Ban}

Get a [`Ban`](@ref).
"""
function unban(c::Client, guild::Int, user::Int)
    return Response{Ban}(c, :GET, "/guilds/$guild/bans/$user")
end

unban(c::Client, g::AbstractGuild, u::Member) = unban(c, g.id, u.id)
unban(c::Client, g::AbstractGuild, u::Int) = unban(c, g.id, u)
unban(c::Client, g::Int, u::Member) = unban(c, g, u.id)

"""
    get_guild_invites(c::Client, guild::Union{AbstractGuild, Integer}) -> Response{Vector{Invite}}

Get the [`Invite`](@ref)s.
"""
function get_guild_invites(c::Client, guild::Int)
    return Response{Invite}(c, :GET, "/guilds/$guild/invites")
end

get_guild_invites(c::Client, g::AbstractGuild) = get_guild_invites(c, g.id)

"""
    create_integration(c::Client
        guild::Union{AbstractGuild, Integer};
        params...
    ) -> Response{Integration}

Create / Attach an [`Integration`](@ref).

# Query Params
- `type::Int`: Integration type.
- `id::Snowflake`: Integration ID.

More details [here](https://discordapp.com/developers/docs/resources/guild#create-guild-integration).
"""
function create_integration(c::Client, guild::Int; params...)
    return Response{Integration}(c, :POST, "/guilds/$guild/integrations"; params...)
end

create_integration(c::Client, g::AbstractGuild; params...) = create_integration(c, g.id; params...)

"""
    get_integrations(c::Client,
        guild::Union{AbstractGuild, Integer}
    ) -> Response{Vector{Integration}}

Get a list of [`Integration`](@ref)s.
"""
function get_integrations(c::Client, guild::Int)
    return Response{Integration}(c, :GET, "/guilds/$guild/integrations")
end

get_integrations(c::Client, guild::AbstractGuild) = get_integrations(c, guild.id)

"""
    get_guild_webhooks(c::Client,
        guild::Union{AbstractGuild, Integer}
    ) -> Response{Vector{Webhook}}

Get a list of [`Webhook`](@ref)s.
"""
function get_guild_webhooks(c::Client, guild::Int)
    return Response{Webhook}(c, :GET, "/guilds/$guild/webhooks")
end

get_guild_webhooks(c::Client, guild::AbstractGuild) = get_guild_webhooks(c, guild.id)

"""
    get_regions(c::Client) -> Response{Vector{VoiceRegion}}

Get a list of [`VoiceRegion`](@ref)s.
"""
function get_regions(c::Client)
    return Response{VoiceRegion}(c, :GET, "/voice/regions")
end

"""
    get_guild_regions(c::Client,
        guild::Union{AbstractGuild, Integer}
    ) -> Response{Vector{VoiceRegion}}

Get a list of [`VoiceRegion`](@ref)s from the given [`AbstractGuild`](@ref).
"""
function get_guild_regions(c::Client, guild::Int)
    return Response{VoiceRegion}(c, :GET, "/guilds/$guild/regions")
end

get_guild_regions(c::Client, guild::AbstractGuild) = get_guild_regions(c, guild.id)

"""
    get_vanity_code(c::Client
        guild::Union{AbstractGuild, Integer}
    ) -> Response{Invite}

Get the vanity code from the given [`AbstractGuild`](@ref).
"""
function get_vanity_code(c::Client, guild::Int)
    return Response{Invite}(c, :GET, "/guilds/$guild/vanity-url")
end

get_vanity_code(c::Client, guild::AbstractGuild) = get_vanity_code(c, guild.id)
