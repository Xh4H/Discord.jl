export create_webhook,
    get_channel_webhooks,
    get_guild_webhooks,
    get_webhook,
    get_webhook_with_token,
    modify_webhook,
    modify_webhook_with_token,
    delete_webhook,
    delete_webhook_with_token,
    execute_webhook,
    execute_slack_compatible_webhook,
    execute_github_compatible_webhook

"""
    create_webhook(c::Client, channel::Integer; kwargs...) -> Webhook

Create a [`Webhook`](@ref) in a [`DiscordChannel`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/webhook#create-webhook).
"""
function create_webhook(c::Client, channel::Integer; kwargs...)
    return Response{Webhook}(c, :POST, "/channels/$channel/webhooks"; body=kwargs)
end

"""
    get_channel_webhooks(c::Client, channel::Integer) -> Vector{Webhook}

Get a list of [`Webhook`](@ref)s in a [`DiscordChannel`](@ref).
"""
function get_channel_webhooks(c::Client, channel::Integer)
    return Response{Vector{Webhook}}(c, :GET, "/channels/$channel/webhooks")
end

"""
    get_guild_webhooks(c::Client, guild::Integer) -> Vector{Webhook}

Get a list of [`Webhook`](@ref)s in a [`Guild`](@ref).
"""
function get_guild_webhooks(c::Client, guild::Integer)
    return Response{Vector{Webhook}}(c, :GET, "/guilds/$guild/webhooks")
end

"""
    get_webhook(c::Client, webhook::Integer) -> Webhook

Get a [`Webhook`](@ref).
"""
function get_webhook(c::Client, webhook::Integer)
    return Response{Webhook}(c, :GET, "/webhooks/$webhook")
end

"""
    get_webhook_with_token(c::Client, webhook::Integer, token::AbstractString) -> Webhook

Get a [`Webhook`](@ref) with a token.
"""
function get_webhook_with_token(c::Client, webhook::Integer, token::AbstractString)
    return Response{Webhook}(c, :GET, "/webhooks/$webhook/$token")
end

"""
    modify_webhook(c::Client, webhook::Integer; kwargs...) -> Webhook

Modify a [`Webhook`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/webhook#modify-webhook).
"""
function modify_webhook(c::Client, webhook::Integer; kwargs...)
    return Response{Webhook}(c, :PATCH, "/webhooks/$webhook"; body=kwargs)
end

"""
    modify_webhook_with_token(
        c::Client,
        webhook::Integer,
        token::AbstractString;
        kwargs...,
    ) -> Webhook

Modify a [`Webhook`](@ref) with a token.
More details [here](https://discordapp.com/developers/docs/resources/webhook#modify-webhook).
"""
function modify_webhook_with_token(
    c::Client,
    webhook::Integer,
    token::AbstractString;
    kwargs...,
)
    return Response{Webhook}(c, :PATCH, "/webhooks/$webhook/$token"; body=kwargs)
end

"""
    delete_webhook(c::Client, webhook::Integer)

Delete a [`Webhook`](@ref).
"""
function delete_webhook(c::Client, webhook::Integer)
    return Response(c, :DELETE, "/webhooks/$webhook")
end

"""
    delete_webhook_with_token(c::Client, webhook::Integer, token::AbstractString)

Delete a [`Webhook`](@ref) with a token.
"""
function delete_webhook_with_token(c::Client, webhook::Integer, token::AbstractString)
    return Response(c, :DELETE, "/webhooks/$webhook/$token")
end

"""
    execute_webhook(
        c::Client,
        webhook::Integer,
        token::AbstractString;
        wait::Bool=false,
        kwargs...,
    ) -> Message

Execute a [`Webhook`](@ref). If `wait` is not set, no [`Message`](@ref) is returned.
More details [here](https://discordapp.com/developers/docs/resources/webhook#execute-webhook).
"""
function execute_webhook(
    c::Client,
    webhook::Integer,
    token::AbstractString;
    wait::Bool=false,
    kwargs...,
)
    return Response{Message}(c, :POST, "/webhooks/$webhook/$token"; body=kwargs, wait=wait)
end

"""
    execute_slack_compatible_webhook(
        c::Client,
        webhook::Integer,
        token::AbstractString;
        wait::Bool=true,
        kwargs...,
    )

Execute a Slack [`Webhook`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/webhook#execute-slackcompatible-webhook).
"""
function execute_slack_compatible_webhook(
    c::Client,
    webhook::Integer,
    token::AbstractString;
    wait::Bool=true,
    kwargs...,
)
    return Response{Message}(
        c,
        :POST,
        "/webhooks/$webhook/$token/slack";
        body=kwargs,
        wait=wait,
    )
end

"""
    execute_github_compatible_webhook(
        c::Client,
        webhook::Integer,
        token::AbstractString;
        wait::Bool=true,
        kwargs...,
    )

Execute a Github [`Webhook`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/webhook#execute-githubcompatible-webhook).
"""
function execute_github_compatible_webhook(
    c::Client,
    webhook::Integer,
    token::AbstractString;
    wait::Bool=true,
    kwargs...,
)
    return Response{Message}(
        c,
        :POST,
        "/webhooks/$webhook/$token/github";
        body=kwargs,
        wait=wait,
    )
end
