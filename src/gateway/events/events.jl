export AbstractEvent,
    FallbackEvent,
    UnknownEvent

"""
An incoming event sent over the gateway. Also a catch-all event: Handlers defined on this
type will execute on all events, before the specific handlers run.
"""
abstract type AbstractEvent end

"""
A type for defining handlers on any events which would otherwise have no non-default
handler. Handlers for this type must accept an [`AbstractEvent`](@ref).
"""
abstract type FallbackEvent <: AbstractEvent end

function mock(::Union{Type{AbstractEvent}, Type{FallbackEvent}})
    subs = subtypes(AbstractEvent)
    return mock(subs[rand(1:length(subs))])
end

"""
An unknown event. When an event can't be parsed, due to an unknown type or any other error,
it will appear as an `UnknownEvent`. The fields follow the schema defined
[here](https://discordapp.com/developers/docs/topics/gateway#payloads).
"""
struct UnknownEvent <: AbstractEvent
    t::String
    d::Dict{Symbol, Any}
    s::Union{Int, Nothing}
end
@boilerplate UnknownEvent :mock
UnknownEvent(; kwargs...) = UnknownEvent(kwargs[:t], kwargs[:d], kwargs[:s])
UnknownEvent(d::Dict{Symbol, Any}) = UnknownEvent(; d...)

include("ready.jl")
include("resumed.jl")
include("channels.jl")
include("guilds.jl")
include("messages.jl")
include("presence.jl")
include("voice.jl")
include("webhooks.jl")

const EVENT_TYPES = Dict{String, Type{<:AbstractEvent}}(
    "READY"                       => Ready,
    "RESUMED"                     => Resumed,
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
    "USER_UPDATE"                 => UserUpdate,
    "VOICE_STATE_UPDATE"          => VoiceStateUpdate,
    "VOICE_SERVER_UPDATE"         => VoiceServerUpdate,
    "WEBHOOKS_UPDATE"             => WebhooksUpdate,
)
