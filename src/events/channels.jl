export ChannelCreate, ChannelUpdate, ChannelDelete, ChannelPinsUpdate

"""
Sent when a new [`DiscordChannel`](@ref) is created.
"""
struct ChannelCreate <: AbstractEvent
    channel::DiscordChannel
end

ChannelCreate(d::Dict{String, Any}) = ChannelCreate(DiscordChannel(d))

JSON.lower(cc::ChannelCreate) = JSON.lower(cc.channel)

"""
Sent when a [`DiscordChannel`](@ref) is updated.
"""
struct ChannelUpdate <: AbstractEvent
    channel::DiscordChannel
end

ChannelUpdate(d::Dict{String, Any}) = ChannelCreate(DiscordChannel(d))

JSON.lower(cu::ChannelUpdate) = JSON.lower(cu.channel)

"""
Sent when a [`DiscordChannel`](@ref) is deleted.
"""
struct ChannelDelete <: AbstractEvent
    channel::DiscordChannel
end

ChannelDelete(d::Dict{String, Any}) = ChannelCreate(DiscordChannel(d))

JSON.lower(cd::ChannelDelete) = JSON.lower(cd.channel)

"""
Sent when a [`DiscordChannel`](@ref)'s pins are updated.
"""
@from_dict struct ChannelPinsUpdate <: AbstractEvent
    channel_id::Snowflake
    last_pin_timestamp::Union{DateTime, Nothing}
end
