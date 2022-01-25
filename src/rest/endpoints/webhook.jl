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
create_webhook(c::Client, channel::Integer; kwargs...) = Response{Webhook}(c, :POST, "/channels/$channel/webhooks"; body = kwargs)

"""
    get_channel_webhooks(c::Client, channel::Integer) -> Vector{Webhook}

Get a list of [`Webhook`](@ref)s in a [`DiscordChannel`](@ref).
"""
get_channel_webhooks(c::Client, channel::Integer) = Response{Vector{Webhook}}(c, :GET, "/channels/$channel/webhooks")

"""
    get_guild_webhooks(c::Client, guild::Integer) -> Vector{Webhook}

Get a list of [`Webhook`](@ref)s in a [`Guild`](@ref).
"""
get_guild_webhooks(c::Client, guild::Integer) = Response{Vector{Webhook}}(c, :GET, "/guilds/$guild/webhooks")

"""
    get_webhook(c::Client, webhook::Integer) -> Webhook

Get a [`Webhook`](@ref).
"""
get_webhook(c::Client, webhook::Integer) = Response{Webhook}(c, :GET, "/webhooks/$webhook")

"""
    get_webhook_with_token(c::Client, webhook::Integer, token::AbstractString) -> Webhook

Get a [`Webhook`](@ref) with a token.
"""
get_webhook_with_token(c::Client, webhook::Integer, token::AbstractString) = Response{Webhook}(c, :GET, "/webhooks/$webhook/$token")

"""
    modify_webhook(c::Client, webhook::Integer; kwargs...) -> Webhook

Modify a [`Webhook`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/webhook#modify-webhook).
"""
modify_webhook(c::Client, webhook::Integer; kwargs...) = Response{Webhook}(c, :PATCH, "/webhooks/$webhook"; body = kwargs)

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
modify_webhook_with_token(
    c::Client,
    webhook::Integer,
    token::AbstractString;
    kwargs...,
) = Response{Webhook}(c, :PATCH, "/webhooks/$webhook/$token"; body = kwargs)

"""
    delete_webhook(c::Client, webhook::Integer)

Delete a [`Webhook`](@ref).
"""
delete_webhook(c::Client, webhook::Integer) = Response(c, :DELETE, "/webhooks/$webhook")

"""
    delete_webhook_with_token(c::Client, webhook::Integer, token::AbstractString)

Delete a [`Webhook`](@ref) with a token.
"""
delete_webhook_with_token(c::Client, webhook::Integer, token::AbstractString) = Response(c, :DELETE, "/webhooks/$webhook/$token")

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
execute_webhook(
    c::Client,
    webhook::Integer,
    token::AbstractString;
    wait::Bool=false,
    kwargs...,
) = Response{Message}(c, :POST, "/webhooks/$webhook/$token"; body = kwargs, wait = wait)

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
execute_slack_compatible_webhook(
    c::Client,
    webhook::Integer,
    token::AbstractString;
    wait::Bool=true,
    kwargs...,
) = Response{Message}(
        c,
        :POST,
        "/webhooks/$webhook/$token/slack";
        body = kwargs,
        wait = wait,
    )

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
execute_github_compatible_webhook(
    c::Client,
    webhook::Integer,
    token::AbstractString;
    wait::Bool=true,
    kwargs...,
) = Response{Message}(
        c,
        :POST,
        "/webhooks/$webhook/$token/github";
        body = kwargs,
        wait = wait,
    )
