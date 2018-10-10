export reply,
    edit,
    delete,
    pin,
    unpin,
    react,
    get_reactions,
    delete_reactions

using HTTP: escapeuri

"""
    reply(c::Client, m::Message, content::Union{String, Dict}) -> Message

Reply to the given [`Message`](@ref) with the given content
upon success or a Dict containing error information.
"""
function reply(c::Client, m::Message, content::Union{String, Dict})
    payload = Dict()

    if isa(content, String)
        payload = Dict("content" => content)
    elseif isa(content, Dict)
        payload = content
        # TODO Handle file uploading here
    end

    err, data = request(c, "POST", "/channels/$(m.channel_id)/messages"; payload=payload)

    return if err
        data
    else
        Message(data)
    end
end

"""
    edit(c::Client, m::Message, content) -> Message

Edit the given [`Message`](@ref) with the given content
upon success or a Dict containing error information.
"""
function edit(c::Client, m::Message, content::Union{String, Dict})
    payload = Dict()

    if isa(content, String)
        payload = Dict("content" => content)
    elseif isa(content, Dict)
        payload = content
    end

    err, data = request(c, "PATCH", "/channels/$(m.channel_id)/messages/$(m.id)"; payload=payload)

    return if err
        data
    else
        Message(data)
    end
end

"""
    delete(c::Client, m::Message) -> Dict

Delete the given [`Message`](@ref)
upon success or a Dict containing error information.
"""
delete(c::Client, m::Message) = request(c, "DELETE", "/channels/$(m.channel_id)/messages/$(m.id)")

"""
    pin(c::Client, m::Message) -> Dict

Pin the given [`Message`](@ref)
upon success or a Dict containing error information.
"""
pin(c::Client, m::Message) = request(c, "PUT", "/channels/$(m.channel_id)/pins/$(m.id)")

"""
    unpin(c::Client, m::Message) -> Dict

Unpin the given [`Message`](@ref)
upon success or a Dict containing error information.
"""
unpin(c::Client, m::Message) = request(c, "DELETE", "/channels/$(m.channel_id)/pins/$(m.id)")

"""
    react(c::Client, m::Message, emoji::String) -> Dict

React to the given [`Message`](@ref) with the given emoji
upon success or a Dict containing error information.
"""
react(c::Client, m::Message, emoji::String) = request(c, "PUT", "/channels/$(m.channel_id)/messages/$(m.id)/reactions/$(escapeuri(emoji))/@me")

"""
    get_reactions(c::Client, m::Message, emoji::String) -> Dict

Retrieve the users who reacted to the given [`Message`](@ref) with the given emoji
upon success or a Dict containing error information.
"""
function get_reactions(c::Client, m::Message, emoji::String)
    # it is unfinished, need to loop though users
    err, data = request(c, "GET", "/channels/$(m.channel_id)/messages/$(m.id)/reactions/$(escapeuri(emoji))")
end

"""
    delete_reactions(c::Client, m::Message) -> Dict

Delete all the reactions from the given [`Message`](@ref)
upon success or a Dict containing error information.
"""
delete_reactions(c::Client, m::Message) = request(c, "DELETE", "/channels/$(m.channel_id)/messages/$(m.id)/reactions")
