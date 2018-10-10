export send_message,
        get_message,
        get_history,
        get_pinned_messages,
        bulk_delete_messages
"""
    send_message(c::Client, ch::DiscordChannel, content::Union{String, Dict}) -> Message

Send a [`Message`](@ref) to the given [`DiscordChannel`](@ref) with the given content.
"""
function send_message(c::Client, ch::DiscordChannel, content::Union{String, Dict})
    payload = Dict()

    if isa(content, String)
        payload = Dict("content" => content)
    elseif isa(content, Dict)
        payload = content
        # TODO Handle file uploading here
    end

    return request(c, "POST", "/channels/$(ch.id)/messages"; payload=payload) |> Message
end

"""
    get_message(c::Client, ch::DiscordChannel, id::Snowflake) -> Message

Get a [`Message`](@ref) from the given [`DiscordChannel`](@ref).
"""
function get_message(c::Client, ch::DiscordChannel, id::Snowflake)
    if !haskey(c.state.messages, id)
        return c.state.messages[id]
    else
        msg = request(c, "GET", "/channels/$(ch.id)/messages/$id") |> Message
        c.state.messages[id] = msg

        return msg
    end
end

"""
    get_history(c::Client, ch::DiscordChannel, query::Dict)

Return a list of [`Message`](@ref)s from the given [`DiscordChannel`](@ref) with the given query.

#### Query
  Must be a keyword list with the fields listed below.
  - `around` - get messages around this message ID
  - `before` - get messages before this message ID
  - `after` - get messages after this message ID
  - `limit` - max number of messages to return

Refer to [this](https://discordapp.com/developers/docs/resources/channel#get-channel-messages)
    for a broader explanation on the fields and their defaults.
"""
function get_history(c::Client, ch::DiscordChannel, query::Dict)
    messages = []
    history = request(c, "GET", "/channels/$(ch.id)/messages"; query=query)

    for msg in history
        push!(messages, Message(msg))
    end

    return messages
end

"""
    get_pinned_messages(c::Client, ch::DiscordChannel)

Return a list of [`Message`](@ref)s pinned in the given [`DiscordChannel`](@ref).
"""
function get_pinned_messages(c::Client, ch::DiscordChannel)
    messages = []
    pins = request(c, "GET", "/channels/$(ch.id)/pins")

    for msg in pins
        push!(messages, Message(msg))
    end

    return messages
end

function bulk_delete_messages(c::Client, ch::DiscordChannel, messages::Array)
    @show request(c, "POST", "/channels/$(ch.id)/messages/bulk-delete")

    for msg in messages
        delete!(c.state.messages, msg)
    end
end
