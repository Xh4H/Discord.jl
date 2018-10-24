export create_guild,
        get_guild,
        modify_guild,
        delete_guild,
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

Delete the given [`Guild`](@ref)s.
"""
function delete_guild(c::Client, guild::Integer)
    return Response{Nothing}(c, :DELETE, "/guilds/$guild")
end

delete_guild(c::Client, g::AbstractGuild) = delete_guild(c, g.id)

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
