export reply,
    edit_message,
    delete_message,
    pin,
    unpin,
    react,
    get_reactions,
    delete_reactions,

"""
    reply(c::Client, m::Message, content::Union{AbstractString, Dict}) -> Response{Message}

Reply to a [`Message`](@ref) (send a message to the same channel).
"""
function reply(c::Client, m::Message, content::Union{AbstractString, Dict})
    return send_message(c, m.channel_id, content)
end

"""
    edit_message(c::Client
        m::Message
        content::Union{AbstractString, Dict},
    ) -> Response{Message}

Edit a [`Message`](@ref).
"""
function edit_message(c::Client, m::Message, content::AbstractDict)
    return Response{Message}(
        c,
        :PATCH,
        "/channels/$(m.channel_id)/messages/$(m.id)";
        body=content,
    )
end

function edit_message(c::Client, m::Message, content::AbstractString)
    return edit_message(c, m, Dict("content" => content))
end

"""
    delete_message(c::Client, m::Message) -> Response

Delete a [`Message`](@ref).
"""
function delete_message(c::Client, m::Message)
    return Response(c, :DELETE, "/channels/$(m.channel_id)/messages/$(m.id)")
end

"""
    pin(c::Client, m::Message) -> Response

Pin a [`Message`](@ref).
"""
function pin(c::Client, m::Message)
    return Response(c, :PUT, "/channels/$(m.channel_id)/pins/$(m.id)")
end

"""
    unpin(c::Client, m::Message) -> Response

Unpin a [`Message`](@ref).
"""
function unpin(c::Client, m::Message)
    return Response(c, :DELETE, "/channels/$(m.channel_id)/pins/$(m.id)")
end

"""
    react(c::Client, m::Message, emoji::AbstractString) -> Response

React to a [`Message`](@ref).
"""
function react(c::Client, m::Message, emoji::AbstractString)
    return Response(
        c,
        :PUT,
        "/channels/$(m.channel_id)/messages/$(m.id)/reactions/$(HTTP.escapeuri(emoji))/@me",
    )
end

"""
    get_reactions(
        c::Client,
        m::Message,
        emoji::Union{Emoji, AbstractString},
    ) -> Response{Vector{User}}

Get the users who reacted to a [`Message`](@ref) with an [`Emoji`](@ref).
"""
function get_reactions(c::Client, m::Message, emoji::AbstractString)
    return Response{User}(
        c,
        :GET,
        "/channels/$(m.channel_id)/messages/$(m.id)/reactions/$(HTTP.escapeuri(emoji))",
    )
end

get_reactions(c::Client, m::Message, e::Emoji) = get_reactions(c, m, e.name)

"""
    delete_reactions(c::Client, m::Message) -> Response

Delete all the reactions from a [`Message`](@ref).
"""
function delete_reactions(c::Client, m::Message)
    return Response(c, :DELETE, "/channels/$(m.channel_id)/messages/$(m.id)/reactions")
end
