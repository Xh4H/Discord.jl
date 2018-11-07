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
    delete_pinned_channel_message,
    group_dm_add_recipient,
    group_dm_remove_recipient

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
    create_reaction(
        c::Client,
        channel::Integer,
        message::Integer,
        emoji::Union{AbstractString, AbstractChar},
    )

React to a [`Message`](@ref).
"""
function create_reaction(
    c::Client,
    channel::Integer,
    message::Integer,
    emoji::Union{AbstractString, AbstractChar},
)
    return Response(
        c,
        :PUT,
        "/channels/$channel/messages/$message/reactions/$(encode_emoji(emoji))/@me",
    )
end

"""
    delete_own_reaction(
        c::Client,
        channel::Integer,
        message::Integer,
        emoji::Union{AbstractString, AbstractChar},
    )

Delete the [`Client`](@ref) user's reaction to a [`Message`](@ref).
"""
function delete_own_reaction(
    c::Client,
    channel::Integer,
    message::Integer,
    emoji::Union{AbstractString, AbstractChar},
)
    return Response(
        c,
        :DELETE,
        "/channels/$channel/messages/$message/reactions/$(encode_emoji(emoji))/@me",
    )
end

"""
    delete_user_reaction(
        c::Client,
        channel::Integer,
        message::Integer,
        emoji::Union{AbstractString, AbstractChar},
        user::Integer,
    )

Delete a [`User`](@ref)'s reaction to a [`Message`](@ref).
"""
function delete_user_reaction(
    c::Client,
    channel::Integer,
    message::Integer,
    emoji::Union{AbstractString, AbstractChar},
    user::Integer,
)
    return Response(
        c,
        :DELETE,
        "/channels/$channel/messages/$message/reactions/$(encode_emoji(emoji))/$user",
    )
end

"""
    get_reactions(
        c::Client,
        channel::Integer,
        message::Integer,
        emoji::Union{AbstractString, AbstractChar},
    ) -> Vector{User}

Get the [`User`](@ref)s who reacted to a [`Message`](@ref) with an [`Emoji`](@ref).
"""
function get_reactions(
    c::Client,
    channel::Integer,
    message::Integer,
    emoji::Union{AbstractString, AbstractChar},
)
    return Response{Vector{User}}(
        c,
        :GET,
        "/channels/$channel/messages/$message/reactions/$(encode_emoji(emoji))",
    )
end

"""
    delete_all_reactions(c::Client, channel::Integer, message::Integer)

Delete all reactions from a [`Message`](@ref).
"""
function delete_all_reactions(c::Client, channel::Integer, message::Integer)
    return Response(c, :DELETE, "/channels/$channel/messages/$message/reactions")
end

"""
    edit_message(c::Client, channel::Integer, message::Integer; kwargs...) -> Message

Edit a [`Message`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/channel#edit-message).
"""
function edit_message(c::Client, channel::Integer, message::Integer; kwargs...)
    return Response{Message}(c, :PATCH, "/channels/$channel/messages/$message"; body=kwargs)
end

"""
    delete_message(c::Client, channel::Integer, message::Integer)

Delete a [`Message`](@ref).
"""
function delete_message(c::Client, channel::Integer, message::Integer)
    return Response(c, :DELETE, "/channels/$channel/messages/$message")
end

"""
    bulk_delete_messages(c::Client, channel::Integer; kwargs...)

Delete multiple [`Message`](@ref)s.
More details [here](https://discordapp.com/developers/docs/resources/channel#bulk-delete-messages).
"""
function bulk_delete_messages(c::Client, channel::Integer; kwargs...)
    return Response(c, :POST, "/channels/$channel/messages/bulk-delete"; body=kwargs...)
end

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
function edit_channel_permissions(
    c::Client,
    channel::Integer,
    overwrite::Integer;
    kwargs...,
)
    return Response(c, :PUT, "/channels/$channel/permissions/$overwrite"; body=kwargs)
end

"""
    get_channel_invites(c::Client, channel::Integer) -> Vector{Invite}

Get the [`Invite`](@ref)s for a [`DiscordChannel`](@ref).
"""
function get_channel_invites(c::Client, channel::Integer)
    return Response{Vector{Invite}}(c, :GET, "/channels/$channel/invites")
end

"""
    create_channel_invite(c::Client, channel::Integer; kwargs...) -> Invite

Create an [`Invite`](@ref) to a [`DiscordChannel`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/channel#create-channel-invite).
"""
function create_channel_invite(c::Client, channel::Integer, kwargs...)
    return Response{Invite}(c, :POST, "/channels/$channel/invites"; body=kwargs)
end

"""
    delete_channel_permission(c::Client, channel::Integer, overwrite::Integer)

Delete an [`Overwrite`](@ref) from a [`DiscordChannel`](@ref).
"""
function delete_channel_permission(c::Client, channel::Integer, overwrite::Integer)
    return Response(c, :DELETE, "/channels/$channel/permissions/$overwrite")
end

"""
    trigger_typing_indicator(c::Client, channel::Integer)

Trigger the typing indicator in a [`DiscordChannel`](@ref).
"""
function trigger_typing_indicator(c::Client, channel::Integer)
    return Response(c, :POST, "/channels/$channel/typing")
end

"""
    get_pinned_messages(c::Client, channel::Integer) -> Vector{Message}

Get the pinned [`Message`](@ref)s in a [`DiscordChannel`](@ref).
"""
function get_pinned_messages(c::Client, channel::Integer)
    return Response{Vector{Message}}(c, :GET, "/channels/$channel/pins")
end

"""
    add_pinned_channel_message(c::Client, channel::Integer, message::Integer)

Pin a [`Message`](@ref) in a [`DiscordChannel`](@ref).
"""
function add_pinned_channel_message(c::Client, channel::Integer, message::Integer)
    return Response(c, :PUT, "/channels/$channel/pins/$message")
end

"""
    delete_pinned_channel_message(c::Client, channel::Integer, message::Integer)

Unpin a [`Message`](@ref) from a [`DiscordChannel`](@ref).
"""
function delete_pinned_channel_message(c::Client, channel::Integer, message::Integer)
    return Response(c, :DELETE, "/channels/$channel/pins/$message")
end

"""
    group_dm_add_recipient(c::Client, channel::Integer, user::Integer; kwargs...)

Add a [`User`](@ref) to a group DM.
More details [here](https://discordapp.com/developers/docs/resources/channel#group-dm-add-recipient).
"""
function group_dm_add_recipient(c::Client, channel::Integer, user::Integer; kwargs...)
    return Response(c, :PUT, "/channels/$channel/recipients/$user"; body=kwargs)
end

"""
    group_dm_remove_recipient(c::Client, channel::Integer, user::Integer)

Remove a [`User`](@ref) from a group DM.
"""
function group_dm_remove_recipient(c::Client, channel::Integer, user::Integer)
    return Response(c, :DELETE, "/channels/$channel/recipients/$user")
end
