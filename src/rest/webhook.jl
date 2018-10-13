export get_webhook,
    modify_webhook,
    delete_webhook,
    execute_webhook,
    execute_github,
    execute_slack

"""
    get_webhook(c::Client, webhook::Union{Webhook, Integer}) -> Response{Webhook}
    get_webhook(
        c::Client,
        webhook::Union{Webhook, Integer},
        token::AbstractString,
    ) -> Response{Webhook}

Get a [`Webhook`](@ref).
"""
function get_webhook(c::Client, webhook::Integer)
    return Response{Webhook}(c, :GET, "/webhooks/$webhook")
end

function get_webhook(c::Client, webhook::Integer, token::AbstractString)
    return Response{Webhook}(c, :GET, "/webhooks/$webhook/$token")
end

get_webhook(c::Client, w::Webhook) = get_webhook(c, w.id)

get_webhook(c::Client, w::Webhook, token::AbstractString) = get_webhook(c, w.id, token)

"""
    modify_webhook(c::Client, webhook::Union{Webhook, Integer}; params...) -> Response{Webhook}
    modify_webhook(
        c::Client,
        webhook::Union{Webhook, Integer},
        token::AbstractString;
        params...,
    ) -> Response{Webhook}

Modify a [`Webhook`](@ref).

# Keywords
- `name::AbstractString`: Name of the webhook.
- `avatar::AbstractString`: Avatar data string.
- `channel_id::Integer`: The channel this webhook should be moved to.

If using a `token`, `channel_id` cannot be used and the returned [`Webhook`](@ref) will not
contain a [`User`](@ref).

More details [here](https://discordapp.com/developers/docs/resources/webhook#modify-webhook).
"""
function modify_webhook(c::Client, webhook::Integer; params...)
    return Response{Webhook}(c, :PATCH, "/webhooks/$webhook"; body=params)
end

function modify_webhook(c::Client, webhook::Integer, token::AbstractString; params...)
    haskey(params, :channel_id) &&
        throw(ArgumentError("channel_id can not be modified using a token"))

    return Response{Webhook}(c, :PATCH, "/webhooks/$webhook/$token"; body=params)
end

function modify_webhook(c::Client, w::Webhook; params...)
    return modify_webhook(c, w.id, params)
end

function modify_webhook(c::Client, w::Webhook, token::AbstractString; params...)
    return modify_webhook(c, w.id, token; params...)
end

"""
    delete_webhook(c::Client, webhook::Union{Webhook, Integer}) -> Response
    delete_webhook(
        c::Client,
        webhook::Union{Webhook, Integer},
        token::AbstractString,
    ) -> Response

Delete a [`Webhook`](@ref).
"""
function delete_webhook(c::Client, webhook::Integer)
    return Response(c, :DELETE, "/webhooks/$webhook")
end

function delete_webhook(c::Client, webhook::Integer, token::AbstractString)
    return Response{Nothing}(c, :DELETE, "/webhooks/$webhook/$token")
end

function delete_webhook(c::Client, w::Webhook)
    return delete_webhook(c, w.id)
end

function delete_webhook(c::Client, w::Webhook, token::AbstractString)
    return delete_webhook(c, w.id, token)
end

"""
    execute_webhook(
        c::Client,
        webhook::Union{Webhook, Integer},
        token::AbstractString;
        wait::Bool=false,
        params...,
    ) -> Union{Response{Message}, Response{Nothing}}

Execute a [`Webhook`](@ref). If `wait` is set, the created [`Message`](@ref) is returned.

# Keywords
- `content::AbstractString`: The message contents (up to 2000 characters).
- `username::AbstractString`: Override the default username of the webhook.
- `avatar_url::AbstractString`: Override the default avatar of the webhook.
- `tts::Bool`: Whether this is a TTS message.
- `file::AbstractDict`: The contents of the file being sent.
- `embeds::AbstractDict`: Embedded `rich` content.

More details [here](https://discordapp.com/developers/docs/resources/webhook#execute-webhook).
"""
function execute_webhook(
    c::Client,
    webhook::Integer,
    token::AbstractString;
    wait::Bool=false,
    params...
)
    return if wait
        Response{Message}(c, :POST, "/webhooks/$webhook/$token"; body=params, wait=wait)
    else
        Response(c, :POST, "/webhooks/$webhook/$token"; body=params)
    end
end

execute_webhook(c::Client, webhook::Webhook, token::AbstractString; wait::Bool=false, params...) = execute_webhook(c, webhook.id, token; wait=wait, params...)

"""
    execute_github(
        c::Client,
        webhook::Union{Webhook, Integer},
        token::AbstractString;
        wait::Bool=true,
        params...,
    ) -> Union{Response{Message}, Response{Nothing}}

Execute s *Github* [`Webhook`](@ref).

More details [here](https://discordapp.com/developers/docs/resources/webhook#execute-githubcompatible-webhook).
"""
function execute_github(
    c::Client,
    webhook::Integer,
    token::AbstractString;
    wait::Bool=true,
    params...,
)
    return if wait
        Response{Message}(
            c,
            :POST,
            "/webhooks/$webhook/$token/github";
            body=params,
            wait=wait,
        )
    else
        Response(c, :POST, "/webhooks/$webhook/$token/github"; body=params)
    end
end

function execute_github(
    c::Client,
    w::Webhook,
    token::AbstractString;
    wait::Bool=false,
    params...,
)
    return execute_github(c, w.id, token; wait=wait, params...)
end

"""
    execute_slack(
        c::Client,
        webhook::Union{Webhook, Integer},
        token::AbstractString;
        wait::Bool=true,
        params...,
    ) -> Union{Response{Message}, Response}

Execute a *Slack* [`Webhook`](@ref).

More details [here](https://discordapp.com/developers/docs/resources/webhook#execute-slackcompatible-webhook).
"""
function execute_slack(
    c::Client,
    webhook::Integer,
    token::AbstractString;
    wait::Bool=true,
    params...,
)
    return if wait
        Response{Message}(
            c,
            :POST,
            "/webhooks/$webhook/$token/slack";
            body=params,
            wait=wait,
        )
    else
        Response(c, :POST, "/webhooks/$webhook/$token/slack"; body=params)
    end
end

function execute_slack(c::Client, w::Webhook, token::AbstractString; wait::Bool=false, params...)
    return execute_slack(c, w.id, token; wait=wait, params...)
end
