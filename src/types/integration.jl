"""
An [`Integration`](@ref) account.
More details [here](https://discordapp.com/developers/docs/resources/guild#integration-account-object).
"""
struct IntegrationAccount
    id::String
    name::String
end
@boilerplate IntegrationAccount :dict :docs :lower :merge

"""
A [`Guild`](@ref) integration.
More details [here](https://discordapp.com/developers/docs/resources/guild#integration-object).
"""
struct Integration
    id::Snowflake
    name::String
    type::String
    enabled::Bool
    syncing::Bool
    role_id::Snowflake
    expire_behaviour::Int
    expire_grace_period::Int
    user::User
    account::IntegrationAccount
    synced_at::DateTime
end
@boilerplate Integration :dict :docs :lower :merge
