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

Reply to the given [`Message`](@ref) with the given content.
"""
function reply(c::Client, m::Message, content::Union{String, Dict})
    payload = Dict()

    if isa(content, String)
        payload = Dict("content" => content)
    elseif isa(content, Dict)
        payload = content
        # TODO Handle file uploading here
    end

    return request(c, "POST", "/channels/$(m.channel_id)/messages", payload) |> Message
end

"""
    edit(c::Client, m::Message, content) -> Message

Edit the given [`Message`](@ref) with the given content.
"""
function edit(c::Client, m::Message, content::Union{String, Dict})
    payload = Dict()

    if isa(content, String)
        payload = Dict("content" => content)
    elseif isa(content, Dict)
        payload = content
    end

    return request(c, "PATCH", "/channels/$(m.channel_id)/messages/$(m.id)", payload) |> Message
end

"""
    delete(c::Client, m::Message) -> Dict

Delete the given [`Message`](@ref).
"""
delete(c::Client, m::Message) = request(c, "DELETE", "/channels/$(m.channel_id)/messages/$(m.id)")

"""
    pin(c::Client, m::Message) -> Dict

Pin the given [`Message`](@ref).
"""
pin(c::Client, m::Message) = request(c, "PUT", "/channels/$(m.channel_id)/pins/$(m.id)")

"""
    unpin(c::Client, m::Message) -> Dict

Unpin the given [`Message`](@ref).
"""
unpin(c::Client, m::Message) = request(c, "DELETE", "/channels/$(m.channel_id)/pins/$(m.id)")

"""
    react(c::Client, m::Message, emoji::String) -> Dict

React to the given [`Message`](@ref) with the given emoji.
"""
react(c::Client, m::Message, emoji::String) = request(c, "PUT", "/channels/$(m.channel_id)/messages/$(m.id)/reactions/$(escapeuri(emoji))/@me")

"""
    get_reactions(c::Client, m::Message, emoji::String) -> Dict

Retrieve the users who reacted to the given [`Message`](@ref) with the given emoji.
"""
function get_reactions(c::Client, m::Message, emoji::String)
    # Needs test and it is unfinished, need to loop though users
    emoji = contains(emoji, ":") ? escapeuri(emoji) : emoji
    println(emoji)
    reactions = request(c, "GET", "/channels/$(m.channel_id)/messages/$(m.id)/reactions/$emoji")
    println(reactions)
end

"""
    delete_reactions(c::Client, m::Message) -> Dict

Delete all the reactions from the given [`Message`](@ref).
"""
delete_reactions(c::Client, m::Message) = request(c, "DELETE", "/channels/$(m.channel_id)/messages/$(m.id)/reactions")
