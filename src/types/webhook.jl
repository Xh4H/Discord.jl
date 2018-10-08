"""
A Webhook.
More details [here](https://discordapp.com/developers/docs/resources/webhook#webhook-object).
"""
@from_dict struct Webhook
    id::Snowflake
    guild_id::Union{Snowflake, Missing}
    channel_id::Snowflake
    user::Union{User, Missing}
    name::Union{String, Nothing}
    avatar::Union{String, Nothing}
    token::String
end
