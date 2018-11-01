function create(::Type{Webhook}, c::Client, ch::DiscordChannel; kwargs...)
    return create_webhook(c, ch.id; kwargs...)
end

retrieve(::Type{Webhook}, c::Client, ch::DiscordChannel) = get_channel_webhooks(c, ch.id)
retrieve(::Type{Webhook}, c::Client, g::AbstractGuild) = get_guild_webhooks(c, g.id)
retrieve(::Type{Webhook}, c::Client, webhook::Integer) = get_webhook(c, webhook)
function retrieve(::Type{Webhook}, c::Client, webhook::Integer, token::AbstractString)
    return get_webhook_with_token(c, webhook, token)
end

update(c::Client, w::Webhook; kwargs...) = modify_webhook(c, w.id; kwargs...)
function update(c::Client, w::Webhook, token::AbstractString; kwargs...)
    return modify_webhook_with_token(c, w.id, token; kwargs...)
end

delete(c::Client, w::Webhook) = delete_webhook(c, w.id)
function delete(c::Client, w::Webhook, token::AbstractString)
    return delete_webhook_with_token(c, w.id, token)
end
