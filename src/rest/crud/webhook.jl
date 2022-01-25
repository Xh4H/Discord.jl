create(c::Client, ::Type{Webhook}, ch::DiscordChannel; kwargs...) = create_webhook(c, ch.id; kwargs...)

retrieve(c::Client, ::Type{Webhook}, ch::DiscordChannel) = get_channel_webhooks(c, ch.id)
retrieve(c::Client, ::Type{Webhook}, g::AbstractGuild) = get_guild_webhooks(c, g.id)
retrieve(c::Client, ::Type{Webhook}, webhook::Integer) = get_webhook(c, webhook)
retrieve(c::Client, ::Type{Webhook}, webhook::Integer, token::AbstractString) = get_webhook_with_token(c, webhook, token)

update(c::Client, w::Webhook; kwargs...) = modify_webhook(c, w.id; kwargs...)
update(c::Client, w::Webhook, token::AbstractString; kwargs...) = modify_webhook_with_token(c, w.id, token; kwargs...)

delete(c::Client, w::Webhook) = delete_webhook(c, w.id)
delete(c::Client, w::Webhook, token::AbstractString) = delete_webhook_with_token(c, w.id, token)
