export send_message,
        get_message,
        get_history,
        get_pinned_messages,
        bulk_delete_messages
"""
    send_message(c::Client, ch::DiscordChannel, content::Union{String, Dict}) -> Message

Send a [`Message`](@ref) to the given [`DiscordChannel`](@ref) with the given content
upon success or a Dict containing error information.
"""
function send_message(c::Client, ch::DiscordChannel, content::Union{String, Dict})
    payload = Dict()

    if isa(content, String)
        payload = Dict("content" => content)
    elseif isa(content, Dict)
        payload = content
        # TODO Handle file uploading here
    end

    err, data = request(c, "POST", "/channels/$(ch.id)/messages"; payload=payload)
    return if err
        data
    else
        Message(data)
    end
end

"""
    get_message(c::Client, ch::DiscordChannel, id::Snowflake) -> Message

Get a [`Message`](@ref) from the given [`DiscordChannel`](@ref)
upon success or a Dict containing error information.
"""
function get_message(c::Client, ch::DiscordChannel, id::Snowflake)
    return if !haskey(c.state.messages, id)
        c.state.messages[id]
    else
        err, data = request(c, "GET", "/channels/$(ch.id)/messages/$id")

        return if err
            data
        else
            msg = Message(data)
            c.state.messages[id] = msg
        end
    end
end

"""
    get_history(c::Client, ch::DiscordChannel, query::Dict) -> Array

Return a list of [`Message`](@ref)s from the given [`DiscordChannel`](@ref) with the given query
upon success or a Dict containing error information.

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
    err, data = request(c, "GET", "/channels/$(ch.id)/messages"; query=query)

    return if err
        data
    else
        for msg in data
            push!(messages, Message(msg))
        end
        messages
    end
end

"""
    get_pinned_messages(c::Client, ch::DiscordChannel) -> Array

Return a list of [`Message`](@ref)s pinned in the given [`DiscordChannel`](@ref)
upon success or a Dict containing error information.
"""
function get_pinned_messages(c::Client, ch::DiscordChannel)
    messages = []
    err, data = request(c, "GET", "/channels/$(ch.id)/pins")

    return if err
        data
    else
        for msg in data
            push!(messages, Message(msg))
        end
        messages
    end
end

"""
    bulk_delete_messages(c::Client, ch::DiscordChannel, messages::Array) -> Bool

Return whether the request was successful; An exception is raised when failed.
"""
function bulk_delete_messages(c::Client, ch::DiscordChannel, messages::Array)
    err, data = request(c, "POST", "/channels/$(ch.id)/messages/bulk-delete"; payload=Dict("messages" => messages))
    return if err
        # @throw(data)
        false
    else
        if !isempty(data) # was erroring with iterate(::Nothing)
            for msg in data
                delete!(c.state.messages, msg)
            end
        end
        true
    end

end

"""
    trigger_typing(c::Client, ch::DiscordChannel) -> Bool

Return whether the request was successful.
"""
trigger_typing(c::Client, ch::DiscordChannel) = request(c, "POST", "/channels/$(ch.id)/typing")
