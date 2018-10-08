export WebhookUpdate

@from_dict struct WebhookUpdate <: AbstractEvent
    guild_id::Snowflake
    channel_id::Snowflake
end
