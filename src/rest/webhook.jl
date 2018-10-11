export get_webhook,
    modify_webhook,
    delete_webhook,
    execute_webhook,
    execute_slack,
    execute_github

"""
    get_webhook(c::Client, webhook::Snowflake) -> Response{Webhook}
    get_webhook(c::Client, webhook::Snowflake, token::AbstractString) -> Response{Webhook}

Get a [`Webhook`](@ref).
"""
function get_webhook(c::Client, webhook::Snowflake)
    return Response{Webhook}(c, :GET, "/webhook/$webhook")
end

function get_webhook(c::Client, webhook::Snowflake, token::AbstractString)
    return Response{Webhook}(c, :GET, "/webhook/$webhook/$token")
end

"""
    modify_webhook(c::Client, webhook::Snowflake; params...) -> Response{Webhook}
    modify_webhook(
        c::Client,
        webhook::Snowflake,
        token::AbstractString;
        params...
    ) -> Response{Webhook}

Modify the given [`Webhook`](@ref).

# Keywords
- `name::AbstractString`: Name of the webhook.
- `avatar::AbstractString`: [Avatar data](https://discordapp.com/developers/docs/resources/user#avatar-data) string.
- `channel_id::Snowflake`: The channel this webhook should be moved to.

If using a `token`, `channel_id` cannot be used and the returned [`Webhook`](@ref) will not
contain a [`User`](@ref).

More details [here](https://discordapp.com/developers/docs/resources/webhook#modify-webhook).
"""
function modify_webhook(c::Client, webhook::Snowflake; params...)
    return Response{Webhook}(c, :PATCH, "/webhooks/$webhook"; body=params)
end

function modify_webhook(c::Client, webhook::Snowflake, token::AbstractString; params...)
    :channel_id in params &&
        throw(ArgumentError("channel_id can not be modified using a token"))

    return Response{Webhook}(c, :PATCH, "/webhooks/$webhook/$token"; body=params)
end

"""
    delete_webhook(c::Client, webhook::Snowflake) -> Response{Nothing}
    delete_webhook(c::Client, webhook::Snowflake, token::AbstractString) -> Response{Nothing}

Delete the given [`Webhook`](@ref).
"""
function delete_webhook(c::Client, webhook::Snowflake)
    return Response{Nothing}(c, :DELETE, "/webhooks/$webhook")
end

function delete_webhook(c::Client, webhook::Snowflake, token::AbstractString)
    return Response{Nothing}(c, :DELETE, "/webhooks/$webhook/$token")
end

"""
    execute_webhook(
        c::Client,
        webhook::Snowflake,
        token::AbstractString;
        wait::Bool=false,
        params...,
    ) -> Union{Response{Message}, Response{Nothing}}

Execute the given [`Webhook`](@ref). If `wait` is set, the created message is returned.

# Keywords
- `content::AbstractString`: The message contents (up to 2000 characters).
- `username::AbstractString`: Override the default username of the webhook.
- `avatar_url::AbstractString`: Override the default avatar of the webhook.
- `tts::Bool`: Whether this is a TTS message.
- `file::Dict`: The contents of the file being sent.
- `embeds::Dict`: Embedded `rich` content.

More details [here](https://discordapp.com/developers/docs/resources/webhook#execute-webhook).
"""
function execute_webhook(
    c::Client,
    webhook::Snowflake,
    token::AbstractString;
    wait::Bool=false,
    params...,
)
    return if wait
        Response{Message}(c, :POST, "/webhooks/$webhook/$token"; body=params, wait=wait)
    else
        Response{Nothing}(c, :POST, "/webhooks/$webhook/$token"; body=params)
    end
end

"""
    execute_slack(
        c::Client,
        webhook::Snowflake,
        token::AbstractString;
        wait::Bool=true,
        params...,
    ) -> Response{Union{Message, Nothing}}

Execute the given *Slack* [`Webhook`](@ref).
"""
function execute_slack(
    c::Client,
    webhook::Snowflake,
    token::AbstractString;
    wait::Bool=true,
    params...,
)
    return if wait
        Response{Message}(c, :POST, "/webhooks/$webhook/$token/slack"; body=params, wait=wait)
    else
        Response{Nothing}(c, :POST, "/webhooks/$webhook/$token/slack"; body=params)
    end
end

"""
    execute_github(
        c::Client,
        webhook::Snowflake,
        token::AbstractString;
        wait::Bool=true,
        params...,
    ) -> Response{Union{Message, Nothing}}

Execute the given *Github* [`Webhook`](@ref).
"""
function execute_github(
    c::Client,
    webhook::Snowflake,
    token::AbstractString;
    wait::Bool=true,
    params...,
)
    return if wait
        Response{Message}(c, :POST, "/webhooks/$webhook/$token/github"; body=params, wait=wait)
    else
        Response{Nothing}(c, :POST, "/webhooks/$webhook/$token/github"; body=params)
    end
end
