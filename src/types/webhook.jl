export Webhook

"""
A Webhook.
More details [here](https://discordapp.com/developers/docs/resources/webhook#webhook-object).
"""
struct Webhook
    id::Snowflake
    guild_id::Union{Snowflake, Missing}
    channel_id::Snowflake
    user::Union{User, Missing}
    name::Union{String, Nothing}
    avatar::Union{String, Nothing}
    token::Union{String, Missing}  # Missing in audit log entries.
end
@boilerplate Webhook :constructors :docs :lower :merge
