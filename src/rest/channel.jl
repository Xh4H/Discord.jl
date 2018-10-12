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
    send_message(
        c::Client,
        channel::Union{DiscordChannel, Integer},
        content::Union{AbstractString, Dict},
    ) -> Response{Message}

Send a [`Message`](@ref) to a [`DiscordChannel`](@ref).
"""
function send_message(c::Client, channel::Integer, content::AbstractString)
    body = Dict("content" => content)
    return Response{Message}(c, :POST, "/channels/$channel/messages"; body=body)
end

function send_message(c::Client, channel::Integer, content::Dict)
    return Response{Message}(c, :POST, "/channels/$channel/messages"; body=content)
end

function send_message(
    c::Client,
    channel::DiscordChannel,
    content::Union{AbstractString, Dict},
)
    return send_message(c, channel.id, content)
end

"""
    get_message(c::Client, message::Message) -> Response{Message}
    get_message(c::Client, channel::Integer, id::Integer) -> Response{Message}

Get a [`Message`](@ref) from a [`DiscordChannel`](@ref).
"""
function get_message(c::Client, channel::Integer, id::Integer)
    return if isopen(c) && haskey(c.state.messages, id)
        Response{Message}(c.state.messages[id])
    else
        resp = Response{Message}(c, :GET, "/channels/$channel/messages/$id")
        if resp.success
            c.state.messages[id] = resp.val
        end
        resp
    end
end

get_message(c::Client, m::Message) = get_message(c, m.channel_id, m.id)

"""
    get_messages(
        c::Client,
        channel::Union{DiscordChannel, Integer};
        params...,
    ) -> Response{Vector{Message}}

Get a list of [`Message`](@ref)s from a [`DiscordChannel`](@ref).

# Keywords
- `around::Integer`: Get messages around this message ID.
- `before::Integer`: Get messages before this message ID.
- `after::Integer`: Get messages after this message ID.
- `limit::Int`: Maximum number of messages.

More details [here](https://discordapp.com/developers/docs/resources/channel#get-channel-messages).
"""
function get_messages(c::Client, channel::Integer; params...)
    return Response{Message}(c, :GET, "/channels/$channel/messages"; params...)
end

function get_messages(c::Client, channel::DiscordChannel; params...)
    return get_messages(c, channel.id; params...)
end

"""
    get_pinned_messages(
        c::Client,
        channel::Union{DiscordChannel, Integer},
    ) -> Response{Vector{Message}}

Get a list of [`Message`](@ref)s pinned in a [`DiscordChannel`](@ref).
"""
function get_pinned_messages(c::Client, channel::Integer)
    # TODO: Use the cache.
    return Response{Message}(c, :GET, "/channels/$channel/pins")
end

get_pinned_messages(c::Client, channel::DiscordChannel) = get_pinned_messages(c, channel.id)

"""
    bulk_delete(
        c::Client,
        channel::Union{DiscordChannel, Integer},
        ids::Vector{<:Integer},
    ) -> Response

Delete multiple [`Message`](@ref)s from a [`DiscordChannel`](@ref).
"""
function bulk_delete(c::Client, channel::Integer, ids::Vector{<:Integer})
    body = Dict("messages" => ids)
    return Response(c, :POST, "/channels/$channel/messages/bulk-delete"; body=body)
end

function bulk_delete(c::Client, channel::DiscordChannel, ids::Vector{<:Integer})
    return get_pinned_messages(c, channel.id, ids)
end

"""
    trigger_typing(c::Client, channel::Union{DiscordChannel, Integer}) -> Response

Trigger the typing indicator in a [`DiscordChannel`](@ref).
"""
function trigger_typing(c::Client, channel::Integer)
    return Response(c, :POST, "/channels/$channel/typing")
end

trigger_typing(c::Client, ch::DiscordChannel) = trigger_typing(c, ch.id)

"""
    modify_channel(
        c::Client,
        channel::Union{DiscordChannel, Integer};
        params...,
    ) -> Response{Channel}

Modify a [`DiscordChannel`](@ref).

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
    (haskey(params, :bitrate) || haskey(params, :user_limit)) &&
        haskey(c.state.channels, channel) &&
        c.state.channels[channel].type === CT_GUILD_VOICE &&
        throw(ArgumentError(
            "Bitrate and user limit can only be modified for voice channels",
        ))

    return Response{Channel}(c, :PATCH, "/channels/$channel"; body=params)
end

function modify_channel(c::Client, ch::DiscordChannel; params...)
    return modify_channel(c, ch.id; params...)
end

"""
    delete_channel(c::Client, channel:::Union{DiscordChannel, Integer}) -> Response{Channel}

Delete a [`DiscordChannel`](@ref).
"""
function delete_channel(c::Client, channel::Integer)
    return Response{Channel}(c, :DELETE, "/channels/$channel")
end

delete_channel(c::Client, ch::DiscordChannel) = delete_channel(c, ch.id)

"""
    create_invite(
        c::Client,
        channel::Union{DiscordChannel, Integer};
        params...,
    ) -> Response{Invite}

Create an [`Invite`](@ref) to a [`DiscordChannel`](@ref).

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
    # This would require one of Response or Invite to be mutable.
end

create_invite(c::Client, ch::DiscordChannel; params...) = create_invite(c, ch.id; params...)

"""
    get_invites(
        c::Client,
        channel::Union{DiscordChannel, Integer},
    ) -> Response{Vector{Invite}}

Get a list of [`Invite`](@ref)s from a [`DiscordChannel`](@ref).
"""
function get_invites(c::Client, channel::Integer)
    return Response{Invite}(c, :GET, "/channels/$channel/invites")
    # See create_invite TODO.
end

get_invites(c::Client, ch::DiscordChannel) = get_invites(c, ch.id)

"""
    create_webhook(
        c::Client,
        channel::Union{DiscordChannel, Integer},
        params...,
    ) -> Response

Create a [`Webhook`](@ref) in a [`DiscordChannel`](@ref).

# Keywords
- `name::AbstractString` - name of the webhook (2-23 characters)
- `avatar::AbstractString` - image for the default webhook avatar

More details [here](https://discordapp.com/developers/docs/resources/webhook#create-webhook).
"""
function create_webhook(c::Client, channel::Integer, params...)
    return Response{Webhook}(c, :POST, "/channels/$channel/webhooks"; body=params)
end

function create_webhook(c::Client, ch::DiscordChannel; params...)
    return create_webhook(c, ch.id; params...)
end

"""
    get_webhooks(
        c::Client,
        channel::Union{DiscordChannel, Integer},
    ) -> Response{Vector{Webhook}}

Get a list of [`Webhook`](@ref)s from a [`DiscordChannel`](@ref).
"""
function get_webhooks(c::Client, channel::Integer)
    return Response{Webhook}(c, :GET, "/channels/$channel/webhooks")
    # See create_invite TODO.
end

get_webhooks(c::Client, ch::DiscordChannel) = get_webhooks(c, ch.id)
