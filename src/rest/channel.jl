export send_message,
    get_message,
    get_messages,
    get_pinned_messages,
    get_channel,
    bulk_delete,
    trigger_typing,
    edit_channel,
    delete_channel,
    create_invite,
    get_channel_invites,
    create_webhook,
    get_channel_webhooks

"""
    send_message(
        c::Client,
        channel::Union{DiscordChannel, Integer},
        content::Union{AbstractString, AbstractDict},
    ) -> Response{Message}

Send a [`Message`](@ref) to a [`DiscordChannel`](@ref).
"""
function send_message(c::Client, channel::Integer, content::AbstractDict)
    return Response{Message}(c, :POST, "/channels/$channel/messages"; body=content)
end

function send_message(c::Client, channel::Integer, content::AbstractString)
    return send_message(c, channel, Dict("content" => content))
end

function send_message(
    c::Client,
    ch::DiscordChannel,
    content::Union{AbstractString, AbstractDict},
)
    return send_message(c, ch.id, content)
end

"""
    get_message(
        c::Client,
        channel::Union{DiscordChannel, Integer},
        message::Integer,
    ) -> Response{Message}
    get_message(c::Client, m::Message) -> Response{Message}

Get a [`Message`](@ref) from a [`DiscordChannel`](@ref).
"""
function get_message(c::Client, channel::Integer, message::Integer)
    return Response{Message}(c, :GET, "/channels/$channel/messages/$message")
end

function get_message(c::Client, m::Message)
    return get_message(c, m.channel_id, m.id)
end

function get_message(c::Client, ch::DiscordChannel, message::Integer)
    return get_message(c, ch.id, message)
end

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
- `limit::Integer`: Maximum number of messages.

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

Get the pinned [`Message`](@ref)s in a [`DiscordChannel`](@ref).
"""
function get_pinned_messages(c::Client, channel::Integer)
    return Response{Message}(c, :GET, "/channels/$channel/pins")
end

get_pinned_messages(c::Client, channel::DiscordChannel) = get_pinned_messages(c, channel.id)

"""
    get_channel(
        c::Client,
        channel::Union{DiscordChannel, Integer},
    ) -> Response{DiscordChannel}

Get a [`DiscordChannel`](@ref).
"""
function get_channel(c::Client, channel::Integer)
    return Response{DiscordChannel}(c, :GET, "/channels/$guild")
end

get_channel(c::Client, ch::DiscordChannel) = get_channel(c, ch.id)

"""
    bulk_delete(
        c::Client,
        channel::Union{DiscordChannel, Integer},
        messages::Union{Vector{Message}, Vector{<:Integer}},
    ) -> Response

Delete multiple [`Message`](@ref)s from a [`DiscordChannel`](@ref).
"""
function bulk_delete(c::Client, channel::Integer, messages::Vector{<:Integer})
    return Response(
        c,
        :POST,
        "/channels/$channel/messages/bulk-delete";
        body=Dict("messages" => messages),
    )
end

function bulk_delete(c::Client, ch::DiscordChannel, messages::Vector{<:Integer})
    return bulk_delete(c, channel.id, messages)
end

function bulk_delete(c::Client, ch::DiscordChannel, ms::Vector{Message})
    return bulk_delete(c, ch.id, map(m -> m.id, ms))
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
    edit_channel(
        c::Client,
        channel::Union{DiscordChannel, Integer};
        params...,
    ) -> Response{DiscordChannel}

Modify a [`DiscordChannel`](@ref).

# Keywords
- `name::AbstractString`: Channel name (2-100 characters).
- `topic::AbstractString`: Channel topic (up to 1024 characters).
- `nsfw::Bool`: Whether the channel is NSFW.
- `rate_limit_per_user::Integer`: Seconds a user must wait before sending another message.
- `position::Integer`: The position in the left-hand listing.
- `bitrate::Integer`: The bitrate in bits of the voice channel.
- `user_limit::Integer`: The user limit of the voice channel.
- `permission_overwrites::Vector{Union{<:AbstractDict, Overwrite}}`: Channel or
  category-specific permissions.
- `parent_id::Integer`: ID of the new parent category.

More details [here](https://discordapp.com/developers/docs/resources/channel#modify-channel).
"""
function edit_channel(c::Client, channel::Integer; params...)
    (haskey(params, :bitrate) || haskey(params, :user_limit)) &&
        haskey(c.state.channels, channel) &&
        c.state.channels[channel].type === CT_GUILD_VOICE &&
        throw(ArgumentError(
            "Bitrate and user limit can only be modified for voice channels",
        ))

    return Response{DiscordChannel}(c, :PATCH, "/channels/$channel"; body=params)
end

edit_channel(c::Client, ch::DiscordChannel; params...) = edit_channel(c, ch.id; params...)

"""
    delete_channel(
        c::Client,
        channel:::Union{DiscordChannel, Integer},
    ) -> Response{DiscordChannel}

Delete a [`DiscordChannel`](@ref).
"""
function delete_channel(c::Client, channel::Integer)
    return Response{DiscordChannel}(c, :DELETE, "/channels/$channel")
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
- `max_uses::Integer`: Max number of uses (0 if unlimited).
- `max_age::Integer`: Duration in seconds before expiry (0 if never).
- `temporary::Bool`: Whether this invite only grants temporary membership.
- `unique::Bool`: Whether not to try to reuse a similar invite.

More details [here](https://discordapp.com/developers/docs/resources/channel#create-channel-invite).
"""
function create_invite(c::Client, channel::Integer, params...)
    return Response{Invite}(c, :POST, "/channels/$channel/invites"; body=params)
end

create_invite(c::Client, ch::DiscordChannel; params...) = create_invite(c, ch.id; params...)

"""
    get_channel_invites(
        c::Client,
        channel::Union{DiscordChannel, Integer},
    ) -> Response{Vector{Invite}}

Get a list of [`Invite`](@ref)s from a [`DiscordChannel`](@ref).
"""
function get_channel_invites(c::Client, channel::Integer)
    return Response{Invite}(c, :GET, "/channels/$channel/invites")
end

get_channel_invites(c::Client, ch::DiscordChannel) = get_channel_invites(c, ch.id)

"""
    create_webhook(
        c::Client,
        channel::Union{DiscordChannel, Integer},
        params...,
    ) -> Response

Create a [`Webhook`](@ref) in a [`DiscordChannel`](@ref).

# Keywords
- `name::AbstractString`: name of the webhook (2-23 characters)
- `avatar::AbstractString`: image for the default webhook avatar

More details [here](https://discordapp.com/developers/docs/resources/webhook#create-webhook).
"""
function create_webhook(c::Client, channel::Integer, params...)
    return Response{Webhook}(c, :POST, "/channels/$channel/webhooks"; body=params)
end

function create_webhook(c::Client, ch::DiscordChannel; params...)
    return create_webhook(c, ch.id; params...)
end

"""
    get_channel_webhooks(
        c::Client,
        channel::Union{DiscordChannel, Integer},
    ) -> Response{Vector{Webhook}}

Get a list of [`Webhook`](@ref)s from a [`DiscordChannel`](@ref).
"""
function get_channel_webhooks(c::Client, channel::Integer)
    return Response{Webhook}(c, :GET, "/channels/$channel/webhooks")
end

get_channel_webhooks(c::Client, ch::DiscordChannel) = get_channel_webhooks(c, ch.id)
