export encode_emoji,
    get_channel,
    modify_channel,
    delete_channel,
    get_channel_messages,
    get_channel_message,
    create_message,
    create_reaction,
    delete_own_reaction,
    delete_user_reaction,
    get_reactions,
    delete_all_reactions,
    edit_message,
    delete_message,
    bulk_delete_messages,
    edit_channel_permissions,
    get_channel_invites,
    create_channel_invite,
    delete_channel_permission,
    trigger_typing_indicator,
    get_pinned_messages,
    add_pinned_channel_message,
    delete_pinned_channel_message

encode_emoji(emoji::AbstractString) = HTTP.escapeuri(emoji)
encode_emoji(emoji::AbstractChar) = encode_emoji(string(emoji))

"""
    get_channel(c::Client, channel::Integer) -> DiscordChannel

Get a [`DiscordChannel`](@ref).
"""
function get_channel(c::Client, channel::Integer)
    return Response{DiscordChannel}(c, :GET, "/channels/$channel")
end

"""
    modify_channel(c::Client, channel::Integer; kwargs...) -> DiscordChannel

Modify a [`DiscordChannel`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/channel#modify-channel).
"""
function modify_channel(c::Client, channel::Integer; kwargs...)
    return Response{DiscordChannel}(c, :PATCH, "/channels/$channel"; body=kwargs)
end

"""
    delete_channel(c::Client, channel::Integer) -> DiscordChannel

Delete a [`DiscordChannel`](@ref).
"""
function delete_channel(c::Client, channel::Integer)
    return Response{DiscordChannel}(c, :DELETE, "/channels/$channel")
end

"""
    get_channel_messages(c::Client, channel::Integer; kwargs...) -> Vector{Message}

Get a list of [`Message`](@ref)s from a [`DiscordChannel`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/channel#get-channel-messages).
"""
function get_channel_messages(c::Client, channel::Integer; kwargs...)
    return Response{Vector{Message}}(c, :GET, "/channels/$channel/messages"; kwargs...)
end

"""
    get_channel_message(c::Client, channel::Integer, message::Integer) -> Message

Get a [`Message`](@ref) from a [`DiscordChannel`](@ref).
"""
function get_channel_message(c::Client, channel::Integer, message::Integer)
    return Response{Message}(c, :GET, "/channels/$channel/messages/$message")
end

"""
    create_message(c::Client, channel::Integer; kwargs...) -> Message

Send a [`Message`](@ref) to a [`DiscordChannel`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/channel#create-message).
"""
function create_message(c::Client, channel::Integer; kwargs...)
    endpoint = "/channels/$channel/messages"
    return if haskey(kwargs, :file)  # We have to use multipart/form-data for file uploads.
        d = Dict(pairs(kwargs))
        file = pop!(d, :file)
        form = HTTP.Form(Dict("file" => file, "payload_json" => json(d)))
        headers = Dict(HTTP.content_type(form))
        Response{Message}(c, :POST, endpoint; headers=headers, body=form)
    else
        Response{Message}(c, :POST, endpoint; body=kwargs)
    end
end

"""
    create_reaction(c::Client, channel::Integer, message::Integer, emoji::StringOrChar)

React to a [`Message`](@ref). If `emoji` is a custom [`Emoji`](@ref), it should be
formatted "name:id".
"""
function create_reaction(c::Client, channel::Integer, message::Integer, emoji::StringOrChar)
    return Response(
        c,
        :PUT,
        "/channels/$channel/messages/$message/reactions/$(encode_emoji(emoji))/@me",
    )
end

"""
    delete_own_reaction(c::Client, channel::Integer, message::Integer, emoji::StringOrChar)

Delete the [`Client`](@ref) user's reaction to a [`Message`](@ref).
"""
delete_own_reaction(
    c::Client,
    channel::Integer,
    message::Integer,
    emoji::StringOrChar,
) = Response(
        c,
        :DELETE,
        "/channels/$channel/messages/$message/reactions/$(encode_emoji(emoji))/@me",
    )

"""
    delete_user_reaction(
        c::Client,
        channel::Integer,
        message::Integer,
        emoji::StringOrChar,
        user::Integer,
    )

Delete a [`User`](@ref)'s reaction to a [`Message`](@ref).
"""
delete_user_reaction(
    c::Client,
    channel::Integer,
    message::Integer,
    emoji::StringOrChar,
    user::Integer,
) = Response(
        c,
        :DELETE,
        "/channels/$channel/messages/$message/reactions/$(encode_emoji(emoji))/$user",
    )

"""
    get_reactions(
        c::Client,
        channel::Integer,
        message::Integer,
        emoji::StringOrChar,
    ) -> Vector{User}

Get the [`User`](@ref)s who reacted to a [`Message`](@ref) with an [`Emoji`](@ref).
"""
get_reactions(c::Client, channel::Integer, message::Integer, emoji::StringOrChar) = Response{Vector{User}}(
        c,
        :GET,
        "/channels/$channel/messages/$message/reactions/$(encode_emoji(emoji))",
    )

"""
    delete_all_reactions(c::Client, channel::Integer, message::Integer)

Delete all reactions from a [`Message`](@ref).
"""
delete_all_reactions(c::Client, channel::Integer, message::Integer) = Response(c, :DELETE, "/channels/$channel/messages/$message/reactions")

"""
    edit_message(c::Client, channel::Integer, message::Integer; kwargs...) -> Message

Edit a [`Message`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/channel#edit-message).
"""
edit_message(c::Client, channel::Integer, message::Integer; kwargs...) = Response{Message}(c, :PATCH, "/channels/$channel/messages/$message"; body = kwargs)

"""
    delete_message(c::Client, channel::Integer, message::Integer)

Delete a [`Message`](@ref).
"""
delete_message(c::Client, channel::Integer, message::Integer) = Response(c, :DELETE, "/channels/$channel/messages/$message")

"""
    bulk_delete_messages(c::Client, channel::Integer; kwargs...)

Delete multiple [`Message`](@ref)s.
More details [here](https://discordapp.com/developers/docs/resources/channel#bulk-delete-messages).
"""
bulk_delete_messages(c::Client, channel::Integer; kwargs...) = Response(c, :POST, "/channels/$channel/messages/bulk-delete"; body = kwargs)

"""
    edit_channel_permissions(
        c::Client,
        channel::Integer,
        overwrite::Integer;
        kwargs...,
    )

Edit permissions for a [`DiscordChannel`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/channel#edit-channel-permissions).
"""
edit_channel_permissions(
    c::Client,
    channel::Integer,
    overwrite::Integer;
    kwargs...,
) = Response(c, :PUT, "/channels/$channel/permissions/$overwrite"; body = kwargs)

"""
    get_channel_invites(c::Client, channel::Integer) -> Vector{Invite}

Get the [`Invite`](@ref)s for a [`DiscordChannel`](@ref).
"""
get_channel_invites(c::Client, channel::Integer) = Response{Vector{Invite}}(c, :GET, "/channels/$channel/invites")

"""
    create_channel_invite(c::Client, channel::Integer; kwargs...) -> Invite

Create an [`Invite`](@ref) to a [`DiscordChannel`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/channel#create-channel-invite).
"""
create_channel_invite(c::Client, channel::Integer, kwargs...) = Response{Invite}(c, :POST, "/channels/$channel/invites"; body = kwargs)

"""
    delete_channel_permission(c::Client, channel::Integer, overwrite::Integer)

Delete an [`Overwrite`](@ref) from a [`DiscordChannel`](@ref).
"""
delete_channel_permission(c::Client, channel::Integer, overwrite::Integer) = Response(c, :DELETE, "/channels/$channel/permissions/$overwrite")

"""
    trigger_typing_indicator(c::Client, channel::Integer)

Trigger the typing indicator in a [`DiscordChannel`](@ref).
"""
trigger_typing_indicator(c::Client, channel::Integer) = Response(c, :POST, "/channels/$channel/typing")

"""
    get_pinned_messages(c::Client, channel::Integer) -> Vector{Message}

Get the pinned [`Message`](@ref)s in a [`DiscordChannel`](@ref).
"""
get_pinned_messages(c::Client, channel::Integer) = Response{Vector{Message}}(c, :GET, "/channels/$channel/pins")

"""
    add_pinned_channel_message(c::Client, channel::Integer, message::Integer)

Pin a [`Message`](@ref) in a [`DiscordChannel`](@ref).
"""
add_pinned_channel_message(c::Client, channel::Integer, message::Integer) = Response(c, :PUT, "/channels/$channel/pins/$message")

"""
    delete_pinned_channel_message(c::Client, channel::Integer, message::Integer)

Unpin a [`Message`](@ref) from a [`DiscordChannel`](@ref).
"""
delete_pinned_channel_message(c::Client, channel::Integer, message::Integer) = Response(c, :DELETE, "/channels/$channel/pins/$message")
