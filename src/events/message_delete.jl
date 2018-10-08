export MessageDelete

"""
A message delete event.
More details [here](https://discordapp.com/developers/docs/topics/gateway#message-delete).
"""
@from_dict struct MessageDelete <: AbstractEvent
    id::Snowflake
    channel_id::Snowflake
    guild_id::Union{Snowflake, Nothing}
end
