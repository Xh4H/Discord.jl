@from_dict struct IntegrationAccount
    id::String
    name::String
end

@from_dict struct Integration
    id::Snowflake
    name::String
    _type::String
    enabled::Bool
    syncing::Bool
    role_id::Snowflake
    expire_behaviour::Int
    expire_grace_period::Int
    user::User
    account::IntegrationAccount
    synced_at::DateTime
end
