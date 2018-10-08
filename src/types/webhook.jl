"""
A Webhook.
More details [here](https://discordapp.com/developers/docs/resources/webhook#webhook-object).
"""
@from_dict struct Webhook
    id::Union{Snowflake, Missing}
    guild_id::Union{Snowflake, Nothing}
    channel_id::Snowflake
    user::User
    name::String
    avatar::String
    token::String
end
