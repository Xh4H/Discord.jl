export send_message,
    get_message,
    get_messages,
    get_pinned_messages,
    bulk_delete,
    trigger_typing

"""
    send_message(c::Client, channel::Snowflake, content::AbstractString) -> Response

Send a [`Message`](@ref) to a [`DiscordChannel`](@ref).
"""
function send_message(c::Client, channel::Snowflake, content::AbstractString)
    body = Dict("content" => content)
    resp = Response{Message}(c, :POST, "/channels/$channel/messages"; body=body)
    if resp.success
        c.state.messages[resp.val.id] = resp.val
    end
    return resp
end

# TODO: send_file(::Client, ::DiscordChannel, ::Dict)

"""
    get_message(c::Client, channel::Snowflake, id::Snowflake) -> Response{Message}

Get a [`Message`](@ref) from a [`DiscordChannel`](@ref).
"""
function get_message(c::Client, channel::Snowflake, id::Snowflake)
    return if haskey(c.state.messages, id)
        Response{Message}(c.state.messages[id])
    else
        resp = Response{Message}(c, :GET, "/channels/$channel/messages/$id")
        if resp.success
            c.state.messages[id] = resp.val
        end
        resp
    end
end

"""
    get_messages(c::Client, channel::Snowflake; params...) -> Response{Vector{Message}}

Get a list of [`Message`](@ref)s from the given [`DiscordChannel`](@ref).

# Keywords
- `around`: Get messages around this message ID.
- `before`: Get messages before this message ID.
- `after`: Get messages after this message ID.
- `limit`: Maximum number of messages.

More details [here](https://discordapp.com/developers/docs/resources/channel#get-channel-messages).
"""
function get_messages(c::Client, channel::Snowflake; params...)
    resp = Response{Message}(c, :GET, "/channels/$channel/messages"; params...)
    if resp.success
        for m in resp.val
            c.state.messages[m.id] = m
        end
    end
    return resp
end

"""
    get_pinned_messages(c::Client, channel::Snowflake) -> Response{Vector{Message}}

Get a list of [`Message`](@ref)s pinned in the given [`DiscordChannel`](@ref).
"""
function get_pinned_messages(c::Client, channel::Snowflake)
    resp = Response{Message}(c, :GET, "/channels/$channel/pins")
    if resp.success
        for m in resp.val
            c.state.messages[m.id] = m
        end
    end
    return resp
end

"""
    bulk_delete(c::Client, channel::Snowflake, ids::Vector{Snowflake}) -> Response

Delete multiple [`Message`](@ref)s from the given [`DiscordChannel`](@ref).
"""
function bulk_delete(c::Client, channel::Snowflake, ids::Vector{Snowflake})
    body = Dict("messages" => messages)
    resp = Response(c, :POST, "/channels/$channel/messages/bulk-delete"; body=body)
    if resp.success
        for id in ids
            delete!(c.state.messages, id)
        end
    end
    return resp
end

"""
    trigger_typing(c::Client, channel::Snowflake) -> Response

Trigger the typing indicator in the given [`DiscordChannel`](@ref).
"""
function trigger_typing(c::Client, ch::DiscordChannel)
    return Response(c, :POST, "/channels/$(ch.id)/typing")
end

"""
    modify_channel(c::Client, channel::Snowflake; params...) -> Response{Channel}

Modify the given [`DiscordChannel`](@ref).

# Keywords
- `name`: Channel name (2-100 characters).
- `topic`: Channel topic (up to 1024 characters).
- `nsfw`: Whether the channel is NSFW.
- `rate_limit_per_user`: Seconds a user must wait before sending another message.
- `position` The position in the left-hand listing.
- `bitrate` The bitrate in bits of the voice channel.
- `user_limit`: The user limit of the voice channel.
- `permission_overwrites`: Channel or category-specific permissions.
- `parent_id`: ID of the new parent category.

More details [here](https://discordapp.com/developers/docs/resources/channel#modify-channel).
"""
function modify_channel(c::Client, channel::Snowflake; params...)
    (bitrate in params || :user_limit in params) && haskey(c.state.channels, channel) &&
        c.state.channels[channel].type === CT_GUILD_VOICE &&
        throw(ArgumentError("Bitrate and user_limit can only be modified for voice channels"))

    resp = Response{Channel}(c, :PATCH, "/channels/$channel"; body=params)
    if resp.success
        c.state.channels[resp.val.id] = resp.val
    end
    return resp
end

# TODO Should we have set_permissions function?

"""
    delete_channel(c::Client, channel::Snowflake) -> Response{Channel}

Delete the given [`DiscordChannel`](@ref).
"""
function delete_channel(c::Client, channel::Snowflake)
    resp = Response{Channel}(c, :DELETE, "/channels/$channel")
    resp.success && delete!(c.state.channels, ch.id)
    return resp
end

"""
    create_invite(c::Client, channel::Snowflake; params...) -> Response{Invite}

Create an [`Invite`](@ref) to the given [`DiscordChannel`](@ref).

# Keywords
- `max_uses`: Max number of uses (0 if unlimited).
- `max_age`: Duration in seconds before expiry (0 if never).
- `temporary`: Whether this invite only grants temporary membership.
- `unique`: Whether not to try to reuse a similar invite.

More details [here](https://discordapp.com/developers/docs/resources/channel#create-channel-invite).
"""
function create_invite(c::Client, channel::Snowflake, params::Dict=Dict())
    return Response{Invite}(c, :POST, "/channels/$channel/invites"; body=params)
    # TODO: add the guild and channel from the cache.
    # This would require Response to be mutable, or to create a brand new Invite.
end
