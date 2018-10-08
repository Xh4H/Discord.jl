"""
A user presence.
More details [here](https://discordapp.com/developers/docs/topics/gateway#presence-update).
"""
@from_dict struct Presence
    user::User
    roles::Vector{Snowflake}
    game::Union{Activity, Missing}
    guild_id::Snowflake
    status::String # should be an enum (either "idle", "dnd", "online", or "offline")
end
