"""
A Webhook.
More details [here](https://discordapp.com/developers/docs/resources/webhook#webhook-objec)t.
"""
@from_dict struct Webhook
    id::Union{Snowflake, Missing}
    guild_id::Union{Snowflake, Nothing}
    channel_id::Snowflake
    user::Union{User, Nothing}
    name::String
    avatar::String
    token::String
end
