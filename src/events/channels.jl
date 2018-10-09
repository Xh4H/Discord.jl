export ChannelCreate, ChannelUpdate, ChannelDelete, ChannelPinsUpdate

struct ChannelCreate <: AbstractEvent
    channel::DiscordChannel
end

ChannelCreate(d::Dict{String, Any}) = ChannelCreate(DiscordChannel(d))

struct ChannelUpdate <: AbstractEvent
    channel::DiscordChannel
end

ChannelUpdate(d::Dict{String, Any}) = ChannelCreate(DiscordChannel(d))

struct ChannelDelete <: AbstractEvent
    channel::DiscordChannel
end

ChannelDelete(d::Dict{String, Any}) = ChannelCreate(DiscordChannel(d))

@from_dict struct ChannelPinsUpdate <: AbstractEvent
    channel_id::Snowflake
    last_pin_timestamp::Union{DateTime, Nothing}
end
