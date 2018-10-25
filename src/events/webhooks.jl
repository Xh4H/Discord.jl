export WebhookUpdate

"""
Sent when a [`DiscordChannel`](@ref)'s [`Webhook`](@ref)s are updated.
"""
struct WebhookUpdate <: AbstractEvent
    guild_id::Snowflake
    channel_id::Snowflake
end
@boilerplate WebhookUpdate :dict :docs
