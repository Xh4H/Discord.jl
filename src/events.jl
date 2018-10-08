export AbstractEvent, UnknownEvent

abstract type AbstractEvent end

"""
An unknown event.
"""
struct UnknownEvent <: AbstractEvent
    t::String
    d::Dict{String, Any}
    s::Union{Int, Nothing}
end

UnknownEvent(data::Dict) = UnknownEvent(data["t"], data["d"], data["s"])

include(joinpath("events", "channels.jl"))
include(joinpath("events", "guilds.jl"))
include(joinpath("events", "messages.jl"))
include(joinpath("events", "presence.jl"))
include(joinpath("events", "voice.jl"))
include(joinpath("events", "webhooks.jl"))

const EVENT_TYPES = Dict{String, Type{<:AbstractEvent}}(
    "CHANNEL_CREATE"              => ChannelCreate,
    "CHANNEL_UPDATE"              => ChannelUpdate,
    "CHANNEL_DELETE"              => ChannelDelete,
    "CHANNEL_PINS_UPDATE"         => ChannelPinsUpdate,
    "GUILD_CREATE"                => GuildCreate,
    "GUILD_UPDATE"                => GuildUpdate,
    "GUILD_DELETE"                => GuildDelete,
    "GUILD_BAN_ADD"               => GuildBanAdd,
    "GUILD_BAN_REMOVE"            => GuildBanRemove,
    "GUILD_EMOJIS_UPDATE"         => GuildEmojisUpdate,
    "GUILD_INTEGRATIONS_UPDATE"   => GuildIntegrationsUpdate,
    "GUILD_MEMBER_ADD"            => GuildMemberAdd,
    "GUILD_MEMBER_REMOVE"         => GuildMemberRemove,
    "GUILD_MEMBER_UPDATE"         => GuildMemberUpdate,
    "GUILD_MEMBERS_CHUNK"         => GuildMembersChunk,
    "GUILD_ROLE_CREATE"           => GuildRoleCreate,
    "GUILD_ROLE_UPDATE"           => GuildRoleUpdate,
    "GUILD_ROLE_DELETE"           => GuildRoleDelete,
    "MESSAGE_CREATE"              => MessageCreate,
    "MESSAGE_UPDATE"              => MessageUpdate,
    "MESSAGE_DELETE"              => MessageDelete,
    "MESSAGE_DELETE_BULK"         => MessageDeleteBulk,
    "MESSAGE_REACTION_ADD"        => MessageReactionAdd,
    "MESSAGE_REACTION_REMOVE"     => MessageReactionRemove,
    "MESSAGE_REACTION_REMOVE_ALL" => MessageReactionRemoveAll,
    "PRESENCE_UPDATE"             => PresenceUpdate,
    "TYPING_START"                => TypingStart,
    "VOICE_STATE_UPDATE"          => VoiceStateUpdate,
    "VOICE_SERVER_UPDAT"          => VoiceServerUpdate,
    "WEBHOOK_UPDATE"              => WebhookUpdate,
)

function AbstractEvent(data::Dict)
    return if haskey(EVENT_TYPES, data["t"])
        EVENT_TYPES[data["t"]](data["d"])
    else
        UnknownEvent(data)
    end
end
