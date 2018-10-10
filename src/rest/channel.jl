export send_message,
        get_message,
        get_history,
        get_pinned_messages,
        bulk_delete,
        trigger_typing
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
    bulk_delete(c::Client, ch::DiscordChannel, messages::Array) -> Bool

Return whether the request was successful; An exception is raised when failed.
"""
function bulk_delete(c::Client, ch::DiscordChannel, messages::Array)
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

"""
    modify(c::Client, ch::DiscordChannel, messages::Array) -> Channel

Modify a given [`DiscordChannel`](@ref) with the given parameters. Return a [`DiscordChannel`](@ref)
upon success or a Dict containing error information.

#### Params
 Must be an enumerable with the fields listed below.
 - `name`                       - channel name (2-100 characters)
 - `topic`                      - channel topic (up to 1024 characters)
 - `nsfw`                       - whether the channel is NSFW
 - `rate_limit_per_user`        - amount of seconds a user has to wait before sending another message
 - `position`                   - the position in the left-hand listing
 - `bitrate`                    - the bitrate in bits of the voice channel
 - `user_limit`                 - the user limit of the voice channel
 - `permission_overwrites`      - channel or category-specific permissions
 - `parent_id`                  - id of the new parent category

 Refer to [this](https://discordapp.com/developers/docs/resources/channel#modify-channel)
 for a broader explanation on the fields and their defaults.
"""
function modify(c::Client, ch::DiscordChannel, params::Dict)
    err, data = request(c, "PATCH", "/channels/$(ch.id)"; payload=params)
    return if err
        data
    else
        DiscordChannel(data)
    end
end

"""
    set_name(c::Client, ch::DiscordChannel, name::String) -> Channel

Modify the name of the given [`DiscordChannel`](@ref) with the given name. Return a [`DiscordChannel`](@ref)
upon success or a Dict containing error information.
"""
set_name(c::Client, ch::DiscordChannel, name::String) = modify(c, ch, Dict("name" => name))

"""
    set_topic(c::Client, ch::DiscordChannel, topic::String) -> Channel

Modify the topic of the given [`DiscordChannel`](@ref) with the given name. Return a [`DiscordChannel`](@ref)
upon success or a Dict containing error information.
"""
set_topic(c::Client, ch::DiscordChannel, topic::String) = modify(c, ch, Dict("topic" => topic))

"""
    set_nsfw(c::Client, ch::DiscordChannel, name::String) -> Channel

Modify the nsfw status of the given [`DiscordChannel`](@ref) with the given name. Return a [`DiscordChannel`](@ref)
upon success or a Dict containing error information.
"""
set_nsfw(c::Client, ch::DiscordChannel, nsfw::Bool) = modify(c, ch, Dict("nsfw" => nsfw))

"""
    set_slowmode(c::Client, ch::DiscordChannel, rate_limit_per_user::Int) -> Channel

Modify the rate limit per user of the given [`DiscordChannel`](@ref) with the given name. Return a [`DiscordChannel`](@ref)
upon success or a Dict containing error information.
"""
set_slowmode(c::Client, ch::DiscordChannel, rate_limit_per_user::Int) = modify(c, ch, Dict("rate_limit_per_user" => rate_limit_per_user))

"""
    set_position(c::Client, ch::DiscordChannel, position::Int) -> Channel

Modify the position of the given [`DiscordChannel`](@ref) with the given name. Return a [`DiscordChannel`](@ref)
upon success or a Dict containing error information.
"""
set_position(c::Client, ch::DiscordChannel, position::Int) = modify(c, ch, Dict("position" => position))

"""
    set_bitrate(c::Client, ch::DiscordChannel, bitrate::Int) -> Channel

Modify the bitrate of the given Voice [`DiscordChannel`](@ref) with the given name. Return a [`DiscordChannel`](@ref)
upon success or a Dict containing error information.
"""
function set_bitrate(c::Client, ch::DiscordChannel, bitrate::Int)
    return if ch.type != CT_GUILD_VOICE
        # @throw "Not a voice channel ........"
    else
        modify(c, ch, Dict("bitrate" => bitrate))
    end
end

"""
    set_user_limit(c::Client, ch::DiscordChannel, user_limit::Int) -> Channel

Modify the user limit of the given Voice [`DiscordChannel`](@ref) with the given name. Return a [`DiscordChannel`](@ref)
upon success or a Dict containing error information.
"""
set_user_limit(c::Client, ch::DiscordChannel, user_limit::Int) = modify(c, ch, Dict("user_limit" => user_limit))


# TODO Should we have set_permissions function?

"""
    set_parent(c::Client, ch::DiscordChannel, parent_id::Int) -> Channel

Modify the parent of the given [`DiscordChannel`](@ref) with the given name. Return a [`DiscordChannel`](@ref)
upon success or a Dict containing error information.
"""
set_parent(c::Client, ch::DiscordChannel, parent_id::Int) = modify(c, ch, Dict("parent_id" => parent_id))

"""
    delete_channel(c::Client, ch::DiscordChannel) -> Channel

Delete the given [`DiscordChannel`](@ref). Return a [`DiscordChannel`](@ref)
upon success or a Dict containing error information.
"""
function delete_channel(c::Client, ch::DiscordChannel)
    err, data = request(c, "DELETE", "/channels/$(ch.id)")

    return if err
        data
    else
        delete!(c.state.channels, ch.id)
        DiscordChannel(data)
    end
end

# https://github.com/satom99/coxir/blob/master/lib/coxir/struct/channel.ex#L316

"""
    create_invite(c::Client, ch::DiscordChannel, params::Dict=Dict()) -> Invite

Create an [`Invite`](@ref). Return a [`DiscordChannel`](@ref)
upon success or a Dict containing error information.

#### Params
 Must be an enumerable with the fields listed below.
 - `max_uses` - max number of uses (0 if unlimited)
 - `max_age` - duration in seconds before expiry (0 if never)
 - `temporary` - whether this invite only grants temporary membership
 - `unique` - whether not to try to reuse a similar invite
 Refer to [this](https://discordapp.com/developers/docs/resources/channel#create-channel-invite)
 for a broader explanation on the fields and their defaults.
"""
function create_invite(c::Client, ch::DiscordChannel, params::Dict=Dict())
    err, data = request(c, "POST", "/channels/$(ch.id)/invites", payload=params)

    return if err
        data
    else
        _beautify(c, data) |> Invite
    end
end
