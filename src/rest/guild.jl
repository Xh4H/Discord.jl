export create_guild,
        get_guild,
        modify_guild,
        delete_guild,
        leave_guild,
        create_role,
        get_webhooks,
        get_regions,
        get_guild_regions,
        get_vanity_code

# functions
"""
    create_guild(c::Client) -> Response{Guild}

Create a [`Guild`](@ref).

# Keywords
- `name::AbstractString`: Guild name (2-100 characters).
- `region::Snowflake`: Desired voice region ID.
- `icon::AbstractString`: Base64 128x128 jpeg image for the guild icon.
- `verification_level::Integer`: Verification level.
- `default_message_notifications::Integer`: Default message notification level.
- `explicit_content_filter::Integer`: Explicit content filter level.
- `roles::Vector{Role}`: New guild roles.
- `channels::Vector{DiscordChannel}`: New guild channels.

More details [here](https://discordapp.com/developers/docs/resources/guild#create-guild).
"""
function create_guild(;params...)
    return Response{Guild}(c, :POST, "/guilds"; body=params)
end

"""
    get_guild(c::Client,
        guild::Union{AbstractGuild, Integer}
    ) -> Response{Guild}

Get a [`Guild`](@ref).
"""
function get_guild(c::Client, guild::Integer)
    return Response{Guild}(c, :GET, "/guilds/$guild")
end

get_guild(c::Client, guild::AbstractGuild) = get_guild(c, guild.id)

"""
    modify_guild(
        c::Client,
        guild::Union{AbstractGuild, Integer};
        params...,
    ) -> Response{Guild}

Modify a [`Guild`](@ref).

# Keywords
- `name::AbstractString`: Guild name (2-100 characters).
- `region::Snowflake`: Desired voice region ID.
- `icon::AbstractString`: Base64 128x128 jpeg image for the guild icon.
- `verification_level::Integer`: Verification level.
- `default_message_notifications::Integer`: Default message notification level.
- `explicit_content_filter::Integer`: Explicit content filter level.
- `afk_channel_id::Snowflake`: ID for afk channel.
- `afk_timeout::Integer`: Afk timeout in seconds.
- `icon::AbstractString`: Base64 128x128 jpeg image for the guild icon.
- `owner_id::Snowflake`: User ID to transfer guild ownership to (must be owner).
- `splash::AbstractString`: Base64 128x128 jpeg image for the guild splash (VIP only).
- `system_channel_id::Snowflake`: The ID of the channel to which system messages are sent.

More details [here](https://discordapp.com/developers/docs/resources/guild#modify-guild).
"""
function modify_guild(c::Client, guild::Integer; params...)
    return Response{Guild}(c, :PATCH, "/guilds/$guild"; body=params)
end

function modify_guild(c::Client, g::AbstractGuild; params...)
    return modify_guild(c, g.id; params...)
end

"""
    delete_guild(c::Client, guild::Union{AbstractGuild, Integer}) -> Response{Nothing}

Delete a [`Guild`](@ref).
"""
function delete_guild(c::Client, guild::Integer)
    return Response{Nothing}(c, :DELETE, "/guilds/$guild")
end

delete_guild(c::Client, g::AbstractGuild) = delete_guild(c, g.id)

"""
    leave_guild(c::Client, guild::Union{AbstractGuild, Integer}) -> Response{Nothing}

Leave a [`Guild`](@ref).
"""
function leave_guild(c::Client, guild::Integer)
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
- `permissions::Integer`: Bitwise value of the enabled/disabled permissions.
- `color::Integer`: RGB color value.
- `hoist::Boolean`: Whether the role should be displayed separately in the sidebar.
- `mentionable::Boolean`: Whether the role should be mentionable.
"""
function create_role(c::Client, guild::Integer; params...)
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
- `position::Integer`: Position of the role.
"""
function edit_role_positions(c::Client, guild::Integer; params...)
    return Response{Role}(c, :PATCH, "/guilds/$guild/roles"; body=params)
end

function edit_role_positions(c::Client, g::AbstractGuild; params...)
    return edit_role_positions(c, g.id; params...)
end

"""
    get_roles(c::Client, guild::Union{AbstractGuild, Integer}) -> Response{Vector{Role}}

Get the [`Role`](@ref)s.
"""
function get_roles(c::Client, guild::Integer)
    return Response{Role}(c, :GET, "/guilds/$guild/roles")
end

get_roles(c::Client, g::AbstractGuild) = get_roles(c, g.id)

"""
    get_webhooks(c::Client,
        guild::Union{AbstractGuild, Integer}
    ) -> Response{Vector{Webhook}}

Get a list of [`Webhook`](@ref)s.
"""
function get_webhooks(c::Client, guild::Integer)
    return Response{Webhook}(c, :GET, "/guilds/$guild/webhooks")
end

get_webhooks(c::Client, guild::AbstractGuild) = get_webhooks(c, guild.id)

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
function get_guild_regions(c::Client, guild::Integer)
    return Response{VoiceRegion}(c, :GET, "/guilds/$guild/regions")
end

get_guild_regions(c::Client, guild::AbstractGuild) = get_guild_regions(c, guild.id)

"""
    get_vanity_code(c::Client
        guild::Union{AbstractGuild, Integer}
    ) -> Response{Invite}

Get the vanity code from the given [`AbstractGuild`](@ref).
"""
function get_vanity_code(c::Client, guild::Integer)
    return Response{Invite}(c, :GET, "/guilds/$guild/vanity-url")
end

get_vanity_code(c::Client, guild::AbstractGuild) = get_vanity_code(c, guild.id)
