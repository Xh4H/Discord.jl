export reply,
    edit,
    delete,
    pin,
    unpin,
    react,
    get_reactions,
    delete_reactions

"""
    reply(c::Client, m::Message, content::AbstractString) -> Response{Message}

Reply to the given [`Message`](@ref) (send a message to the same channel).
"""
function reply(c::Client, m::Message, content::Union{AbstractString, Dict})
    return send_message(c, m.channel.id, content)
end

"""
    edit(c::Client, m::Message, content::AbstractString) -> Response{Message}
    edit(c::Client, m::Message, content::Dict) -> Response{Message}

Edit the given [`Message`](@ref).
"""
function edit(c::Client, m::Message, content::AbstractString)
    body = Dict("content" => content)
    resp = Response{Message}(c, :PATCH, "/channels/$(m.channel_id)/messages"; body=body)
    if resp.success
        c.state.messages[resp.val.id] = resp.val
    end
    return resp
end

function edit(c::Client, m::Message, content::Dict)
    resp = Response{Message}(c, :PATCH, "/channels/$(m.channel_id)/messages/$(m.id)"; body=content)
    if resp.success
        c.state.messages[resp.val.id] = resp.val
    end
    return resp
end

"""
    delete(c::Client, m::Message) -> Response

Delete the given [`Message`](@ref).
"""
function delete(c::Client, m::Message)
    resp = Response(c, :DELETE, "/channels/$(m.channel_id)/messages/$(m.id)")
    resp.success && delete!(c.state.channels, m.id)
    return resp
end

"""
    pin(c::Client, m::Message) -> Response{Message}

Pin the given [`Message`](@ref).
"""
function pin(c::Client, m::Message)
    resp = Response{Message}(c, :PUT, "/channels/$(m.channel_id)/pins/$(m.id)")
    if resp.success
        c.state.messages[m.id] = m
    end
    return resp
end

"""
    unpin(c::Client, m::Message) -> Response{Message}

Unpin the given [`Message`](@ref)
upon success or a Dict containing error information.
"""
function unpin(c::Client, m::Message)
    resp = Response{Message}(c, :DELETE, "/channels/$(m.channel_id)/pins/$(m.id)")
    if resp.success
        c.state.messages[m.id] = m
    end
    return resp
end

"""
    react(c::Client, m::Message, emoji::AbstractString) -> Response

React to the given [`Message`](@ref).
"""
function react(c::Client, m::Message, emoji::AbstractString)
    return Response(
        c,
        :PUT,
        "/channels/$(m.channel_id)/messages/$(m.id)/reactions/$(HTTP.escapeuri(emoji))/@me",
    )
end

"""
    get_reactions(c::Client, m::Message, emoji::AbstractString) -> Response{Vector{User}}

Get the users who reacted to the given [`Message`](@ref) with the given emoji.
"""
function get_reactions(c::Client, m::Message, emoji::AbstractString)
    return Response{User}(
        c,
        :GET,
        "/channels/$(m.channel_id)/messages/$(m.id)/reactions/$(escapeuri(emoji))",
    )
end

"""
    delete_reactions(c::Client, m::Message) -> Dict

Delete all the reactions from the given [`Message`](@ref).
"""
function delete_reactions(c::Client, m::Message)
    return Response(c, :DELETE, "/channels/$(m.channel_id)/messages/$(m.id)/reactions")
end
