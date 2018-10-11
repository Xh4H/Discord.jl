export get_webhook,
        get_webhook_with_token,
        modify_webhook,
        modify_webhook_with_token,
        delete_webhook,
        delete_webhook_with_token,
        execute_webhook,
        execute_slack,
        execute_github

"""
    get_webhook(c::Client, webhook::Snowflake) -> Response{Webhook}

Get a [`Webhook`](@ref).
"""
function get_webhook(c::Client, webhook::Snowflake)
    return Response{Webhook}(c, :GET, "/webhook/$webhook")
end

"""
    get_webhook_with_token(c::Client, webhook::Snowflake, token::AbstractString) -> Response{Webhook}

Get a [`Webhook`](@ref) with the given token.
"""
function get_webhook_with_token(c::Client, webhook::Snowflake, token::AbstractString)
    return Response{Webhook}(c, :GET, "/webhook/$webhook/$token")
end

"""
    modify_webhook(c::Client, webhook::Snowflake; params...) -> Response{Webhook}

Modify the given [`Webhook`](@ref) with the given parameters.

# Keywords
- `name::AbstractString`: name of the webhook.
- `avatar::AbstractString`: [avatar data](https://discordapp.com/developers/docs/resources/user#avatar-data) string.
- `channel_id::Snowflake`: the new channel id this webhook should be moved to.

More details [here](https://discordapp.com/developers/docs/resources/webhook#modify-webhook).
"""
function modify_webhook(c::Client, webhook::Snowflake; params...)
    return Response{Webhook}(c, :PATCH, "/webhooks/$webhook"; params...)
end

"""
    modify_webhook_with_token(c::Client, webhook::Snowflake, token::AbstractString; params...) -> Response{Webhook}

Modify the given [`Webhook`](@ref) with the given parameters. Does not accept a `channel_id` parameter in the body,
and does not return a user in the webhook object.
"""
function modify_webhook_with_token(c::Client, webhook::Snowflake, token::AbstractString; params...)
    :channel_id in params &&
        throw(ArgumentError("channel_id can not be modified using with_token endpoint."))

    return Response{Webhook}(c, :PATCH, "/webhooks/$webhook/$token"; params...)
end

"""
    delete_webhook(c::Client, webhook::Snowflake) -> Response{Nothing}

Delete the given [`Webhook`](@ref).
"""
function delete_webhook(c::Client, webhook::Snowflake)
    return Response{Nothing}(c, :DELETE, "/webhooks/$webhook")
end

"""
    delete_webhook_with_token(c::Client, webhook::Snowflake, token::AbstractString) -> Response{Nothing}

Delete the given [`Webhook`](@ref) with the given token.
"""
function delete_webhook_with_token(c::Client, webhook::Snowflake, token::AbstractString)
    return Response{Nothing}(c, :DELETE, "/webhooks/$webhook/$token")
end

"""
    execute_webhook(c::Client, webhook::Snowflake, token::AbstractString; params...) -> Response{Union{Message, Nothing}}

Execute the given [`Webhook`](@ref) with the given parameters. Return the created message body
(defaults to false; when false a message that is not saved does not return an error).

# Keywords
- `contet::AbstractString`: the message contents (up to 2000 characters).
- `username::AbstractString`: override the default username of the webhook.
- `avatar_url::AbstractString`: override the default avatar of the webhook.
- `tts::Bool`: true if this is a TTS message.
- `file::Dict`: the contents of the file being sent.
- `embeds::Dict`: embedded `rich` content.

More details [here](https://discordapp.com/developers/docs/resources/webhook#execute-webhook).
"""
function execute_webhook(c::Client, webhook::Snowflake, token::AbstractString; params...)
    return Response{Union{Message, Nothing}}(c, :POST, "/webhooks/$webhook/$token"; params...)
end

"""
    execute_slack(c::Client, webhook::Snowflake, token::AbstractString; params...) -> Response{Union{Message, Nothing}}

Execute the given *Slack* Webhook with the given parameters.
"""
function execute_slack(c::Client, webhook::Snowflake, token::AbstractString; params...)
    return Response{Union{Message, Nothing}}(c, :POST, "/webhooks/$webhook/$token/slack"; params...)
end

"""
    execute_github(c::Client, webhook::Snowflake, token::AbstractString; params...) -> Response{Union{Message, Nothing}}

Execute the given *Github* Webhook with the given parameters.
"""
function execute_github(c::Client, webhook::Snowflake, token::AbstractString; params...)
    return Response{Union{Message, Nothing}}(c, :POST, "/webhooks/$webhook/$token/github"; params...)
end
