export send_message,
    get_message,
    get_messages,
    get_pinned_messages,
    bulk_delete,
    trigger_typing,
    modify_channel,
    delete_channel,
    create_invite,
    get_invites,
    create_webhook,
    get_webhooks

"""
    send_message(c::Client, channel::Union{DiscordChannel, Integer}, content::Union{AbstractString, Dict}) -> Response{Message}

Send a [`Message`](@ref) to a [`DiscordChannel`](@ref).
"""
function send_message(c::Client, channel::Integer, content::AbstractString)
    body = Dict("content" => content)
    return Response{Message}(c, :POST, "/channels/$channel/messages"; body=body)
end

function send_message(c::Client, channel::Integer, content::Dict)
    return Response{Message}(c, :POST, "/channels/$channel/messages"; body=content)
end

send_message(c::Client, channel::DiscordChannel, content::Union{AbstractString, Dict}) = send_message(c, channel.id, content)

"""
    get_message(c::Client, msg::Message) -> Response{Message}
    get_message(c::Client, channel::Integer, id::Integer) -> Response{Message}

Get a [`Message`](@ref) from a [`DiscordChannel`](@ref).
"""
function get_message(c::Client, channel::Integer, id::Integer)
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

get_message(c::Client, msg::Message) = get_message(c, msg.channel_id, msg.id)


"""
    get_messages(c::Client, channel::Union{DiscordChannel, Integer}; params...) -> Response{Vector{Message}}

Get a list of [`Message`](@ref)s from the given [`DiscordChannel`](@ref).

# Keywords
- `around::Integer`: Get messages around this message ID.
- `before::Integer`: Get messages before this message ID.
- `after::Integer`: Get messages after this message ID.
- `limit::Int`: Maximum number of messages.

More details [here](https://discordapp.com/developers/docs/resources/channel#get-channel-messages).
"""
function get_messages(c::Client, channel::Integer; params...)
    resp = Response{Message}(c, :GET, "/channels/$channel/messages"; params...)
    if resp.success
        for m in resp.val
            c.state.messages[m.id] = m
        end
    end
    return resp
end

get_messages(c::Client, channel::DiscordChannel; params...) = get_messages(c, channel.id; params...)


"""
    get_pinned_messages(c::Client, channel::Union{DiscordChannel, Integer}) -> Response{Vector{Message}}

Get a list of [`Message`](@ref)s pinned in the given [`DiscordChannel`](@ref).
"""
function get_pinned_messages(c::Client, channel::Integer)
    # TODO: Use the cache.
    resp = Response{Message}(c, :GET, "/channels/$channel/pins")
    if resp.success
        for m in resp.val
            c.state.messages[m.id] = m
        end
    end
    return resp
end

get_pinned_messages(c::Client, channel::DiscordChannel) = get_pinned_messages(c, channel.id)


"""
    bulk_delete(c::Client, channel::Union{DiscordChannel, Integer}, ids::Vector{Snowflake}) -> Response{Nothing}

Delete multiple [`Message`](@ref)s from the given [`DiscordChannel`](@ref).
"""
function bulk_delete(c::Client, channel::Integer, ids::Vector{Snowflake})
    body = Dict("messages" => ids)
    return Response{Nothing}(c, :POST, "/channels/$channel/messages/bulk-delete"; body=body)
end

bulk_delete(c::Client, channel::DiscordChannel, ids::Vector{Snowflake}) = get_pinned_messages(c, channel.id, ids)


"""
    trigger_typing(c::Client, channel::Union{DiscordChannel, Integer}) -> Response{Nothing}

Trigger the typing indicator in the given [`DiscordChannel`](@ref).
"""
trigger_typing(c::Client, ch::Integer) = Response{Nothing}(c, :POST, "/channels/$(ch)/typing")
trigger_typing(c::Client, ch::DiscordChannel) = trigger_typing(c, ch.id)

"""
    modify_channel(c::Client, channel::Union{DiscordChannel, Integer}; params...) -> Response{Channel}

Modify the given [`DiscordChannel`](@ref).

# Keywords
- `name::AbstractString`: Channel name (2-100 characters).
- `topic::AbstractString`: Channel topic (up to 1024 characters).
- `nsfw::Bool`: Whether the channel is NSFW.
- `rate_limit_per_user::Int`: Seconds a user must wait before sending another message.
- `position::Int` The position in the left-hand listing.
- `bitrate::Int` The bitrate in bits of the voice channel.
- `user_limit::Int`: The user limit of the voice channel.
- `permission_overwrites::Vector{Dict}`: Channel or category-specific permissions.
- `parent_id::Integer`: ID of the new parent category.

More details [here](https://discordapp.com/developers/docs/resources/channel#modify-channel).
"""
function modify_channel(c::Client, channel::Integer; params...)
    # TODO: overwrites is a list of Dicts, we should probably allow passing
    # actual Overwrites. Maybe we need to implement JSON.lower for all the types.
    (:bitrate in params || :user_limit in params) && haskey(c.state.channels, channel) &&
        c.state.channels[channel].type === CT_GUILD_VOICE &&
        throw(ArgumentError("Bitrate and user_limit can only be modified for voice channels"))

    resp = Response{Channel}(c, :PATCH, "/channels/$channel"; body=params)
    if resp.success
        c.state.channels[resp.val.id] = resp.val
    end
    return resp
end

modify_channel(c::Client, ch::DiscordChannel; params...) = modify_channel(c, ch.id; params...)

# TODO Should we have set_permissions function?

"""
    delete_channel(c::Client, channel:::Union{DiscordChannel, Integer}) -> Response{Channel}

Delete the given [`DiscordChannel`](@ref).
"""
function delete_channel(c::Client, channel::Integer)
    return Response{Channel}(c, :DELETE, "/channels/$channel")
end

delete_channel(c::Client, ch::DiscordChannel) = delete_channel(c, ch.id)

"""
    create_invite(c::Client, channel::Union{DiscordChannel, Integer}; params...) -> Response{Invite}

Create an [`Invite`](@ref) to the given [`DiscordChannel`](@ref).

# Keywords
- `max_uses::Int`: Max number of uses (0 if unlimited).
- `max_age::Int`: Duration in seconds before expiry (0 if never).
- `temporary::Bool`: Whether this invite only grants temporary membership.
- `unique::Bool`: Whether not to try to reuse a similar invite.

More details [here](https://discordapp.com/developers/docs/resources/channel#create-channel-invite).
"""
function create_invite(c::Client, channel::Integer, params...)
    return Response{Invite}(c, :POST, "/channels/$channel/invites"; body=params)
    # TODO: add the guild and channel from the cache.
    # This would require Response to be mutable, or to create a brand new Invite.
end

create_invite(c::Client, ch::DiscordChannel; params...) = create_invite(c, ch.id; params...)

"""
    get_invites(c::Client, channel::Union{DiscordChannel, Integer}) -> Response{Invite}

Get an Array of [`Invite`](@ref)s from the given [`DiscordChannel`](@ref).
"""
function get_invites(c::Client, channel::Integer)
    return Response{Invite}(c, :GET, "/channels/$channel/invites")
    # Create invite comments
end

get_invites(c::Client, ch::DiscordChannel) = get_invites(c, ch.id)

"""
    create_webhook(c::Client, channel::Union{DiscordChannel, Integer}, params...)

Create a [`Webhook`](@ref) in the given [`DiscordChannel`](@ref).

# Keywords
- `name::AbstractString` - name of the webhook (2-23 characters)
- `avatar::AbstractString` - image for the default webhook avatar

More details [here](https://discordapp.com/developers/docs/resources/webhook#create-webhook).
"""
function create_webhook(c::Client, channel::Integer, params...)
    return Response{Webhook}(c, :POST, "/channels/$channel/webhooks"; body=params)
end

create_webhook(c::Client, ch::DiscordChannel; params...) = create_webhook(c, ch.id; params...)

"""
    get_webhooks(c::Client, channel::Union{DiscordChannel, Integer}) -> Response{Webhook}

Get an Array of [`Webhook`](@ref)s from the given [`DiscordChannel`](@ref).
"""
function get_webhooks(c::Client, channel::Integer)
    return Response{Webhook}(c, :GET, "/channels/$channel/webhooks")
    # Create invite comments
end

get_webhooks(c::Client, ch::DiscordChannel) = get_webhooks(c, ch.id)
