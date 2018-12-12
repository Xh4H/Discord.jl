export Webhook

"""
A Webhook.
More details [here](https://discordapp.com/developers/docs/resources/webhook#webhook-object).
"""
struct Webhook
    id::Snowflake
    guild_id::Optional{Snowflake}
    channel_id::Snowflake
    user::Optional{User}
    name::Nullable{String}
    avatar::Nullable{String}
    token::Optional{String}  # Missing in audit log entries.
end
@boilerplate Webhook :constructors :docs :lower :merge :mock
