export WebhooksUpdate

"""
Sent when a [`DiscordChannel`](@ref)'s [`Webhook`](@ref)s are updated.
"""
struct WebhooksUpdate <: AbstractEvent
    guild_id::Snowflake
    channel_id::Snowflake
end
@boilerplate WebhooksUpdate :constructors :docs :mock
