export ChannelCreate,
    ChannelUpdate,
    ChannelDelete,
    ChannelPinsUpdate

"""
Sent when a new [`DiscordChannel`](@ref) is created.
"""
struct ChannelCreate <: AbstractEvent
    channel::DiscordChannel
end
@boilerplate ChannelCreate :docs
ChannelCreate(; kwargs...) = ChannelCreate(DiscordChannel(; kwargs...))
ChannelCreate(d::Dict{Symbol, Any}) = ChannelCreate(; d...)

"""
Sent when a [`DiscordChannel`](@ref) is updated.
"""
struct ChannelUpdate <: AbstractEvent
    channel::DiscordChannel
end
@boilerplate ChannelUpdate :docs
ChannelUpdate(; kwargs...) = ChannelUpdate(DiscordChannel(; kwargs...))
ChannelUpdate(d::Dict{Symbol, Any}) = ChannelUpdate(; d...)

"""
Sent when a [`DiscordChannel`](@ref) is deleted.
"""
struct ChannelDelete <: AbstractEvent
    channel::DiscordChannel
end
@boilerplate ChannelDelete :docs
ChannelDelete(; kwargs...) = ChannelDelete(DiscordChannel(; kwargs...))
ChannelDelete(d::Dict{Symbol, Any}) = ChannelDelete(; d...)

"""
Sent when a [`DiscordChannel`](@ref)'s pins are updated.
"""
struct ChannelPinsUpdate <: AbstractEvent
    channel_id::Snowflake
    last_pin_timestamp::Union{DateTime, Nothing}
end
@boilerplate ChannelPinsUpdate :constructors :docs
