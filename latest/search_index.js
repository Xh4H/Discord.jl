var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#Discord.jl-1",
    "page": "Home",
    "title": "Discord.jl",
    "category": "section",
    "text": "Discord.jl is the solution for creating Discord bots with the Julia programming language."
},

{
    "location": "index.html#Why-Julia/Discord.jl?-1",
    "page": "Home",
    "title": "Why Julia/Discord.jl?",
    "category": "section",
    "text": "Strong, expressive type system: No fast-and-loose JSON objects here.\nNon-blocking: API calls return immediately and can be awaited when necessary.\nSimple: Multiple dispatch allows for a small, elegant core API.\nFast: Julia is fast like C but still easy like Python.\nRobust: You can\'t crash your bot with a bad event handler or request, and errors are introspectible for debugging.\nLightweight: Cache what\'s important but shed dead weight with TTL.\nGateway independent: Interact with Discord\'s API without establishing a gateway connection.\nDistributed: Process-based sharding requires next to no intervention and you can even run shards on separate machines.For usage examples, see the examples/ directory."
},

{
    "location": "index.html#Index-1",
    "page": "Home",
    "title": "Index",
    "category": "section",
    "text": ""
},

{
    "location": "client.html#",
    "page": "Client",
    "title": "Client",
    "category": "page",
    "text": "CurrentModule = Discord"
},

{
    "location": "client.html#Discord.Client",
    "page": "Client",
    "title": "Discord.Client",
    "category": "type",
    "text": "Client(\n    token::String;\n    presence::Union{Dict, NamedTuple}=Dict(),\n    ttls::Dict{DataType,Union{Nothing, Period}}=Dict(),\n    version::Int=6,\n) -> Client\n\nA Discord bot. Clients can connect to the gateway, respond to events, and make REST API calls to perform actions such as sending/deleting messages, kicking/banning users, etc.\n\nKeywords\n\npresence::Union{Dict, NamedTuple}=Dict(): Bot user\'s presence set upon connection. The schema here must be followed.\nttls::Dict{DataType,Union{Nothing, Period}}=Dict(): Cache lifetime overrides. Values of nothing indicate no expiry. Keys can be any of the following: Guild, DiscordChannel, Message, User, Member, or Presence. For most workloads, the defaults are sufficient.\nversion::Int=6: Version of the Discord API to use. Using anything but 6 is not officially supported by the Discord.jl developers.\n\n\n\n\n\n"
},

{
    "location": "client.html#Base.open",
    "page": "Client",
    "title": "Base.open",
    "category": "function",
    "text": "open(c::Client; delay::Period=Second(7))\n\nConnect to the Discord gateway and begin responding to events.\n\nThe delay keyword is the time between shards connecting. It can be increased from its default if you are frequently experiencing invalid sessions upon connection.\n\n\n\n\n\n"
},

{
    "location": "client.html#Base.isopen",
    "page": "Client",
    "title": "Base.isopen",
    "category": "function",
    "text": "isopen(c::Client) -> Bool\n\nDetermine whether the client is connected to the gateway.\n\n\n\n\n\n"
},

{
    "location": "client.html#Base.close",
    "page": "Client",
    "title": "Base.close",
    "category": "function",
    "text": "close(c::Client)\n\nDisconnect from the Discord gateway.\n\n\n\n\n\n"
},

{
    "location": "client.html#Base.wait",
    "page": "Client",
    "title": "Base.wait",
    "category": "function",
    "text": "wait(c::Client)\n\nWait for an open client to close.\n\n\n\n\n\n"
},

{
    "location": "client.html#Discord.me",
    "page": "Client",
    "title": "Discord.me",
    "category": "function",
    "text": "me(c::Client) -> Union{User, Nothing}\n\nGet the Client\'s bot user.\n\n\n\n\n\n"
},

{
    "location": "client.html#Client-1",
    "page": "Client",
    "title": "Client",
    "category": "section",
    "text": "Client\nBase.open\nBase.isopen\nBase.close\nBase.wait\nme"
},

{
    "location": "client.html#Discord.add_handler!",
    "page": "Client",
    "title": "Discord.add_handler!",
    "category": "function",
    "text": "add_handler!(\n    c::Client,\n    T::Type{<:AbstractEvent},\n    func::Function;\n    tag::Symbol=gensym(),\n    expiry::Union{Int, Period, Nothing}=nothing,\n)\nadd_handler!(\n    func::Function;\n    c::Client,\n    T::Type{<:AbstractEvent},\n    tag::Symbol=gensym(),\n    expiry::Union{Int, Period, Nothing}=nothing,\n)\n\nAdd an event handler. The handler should be a function which takes two arguments: A Client and an AbstractEvent (or a subtype). The handler is appended to the event\'s current handlers. You can also define a single handler for multiple event types by using a Union. do syntax is also accepted.\n\nKeywords\n\ntag::Symbol=gensym(): A label for the handler, which can be used to remove it with delete_handler!.\nexpiry::Union{Int, Period, Nothing}=nothing: The handler\'s expiry. If an Int is given, the handler will run that many times before expiring. If a Period is given, the handler will expire after it elapsed. The default of nothing indicates no expiry.\n\nnote: Note\nThere is no guarantee on the order in which handlers run, except that catch-all (AbstractEvent) handlers run before specific ones.\n\n\n\n\n\nadd_handler!(\n    c::Client,\n    m::Module;\n    tag::Symbol=gensym(),\n    expiry::Union{Int, Period, Nothing}=nothing,\n)\n\nAdd all of the event handlers defined in a module. Any function you wish to use as a handler must be exported. Only functions with correct type signatures (see above) are used.\n\nnote: Note\nIf you specify a tag and/or expiry, it\'s applied to all of the handlers in the module. That means if you add two handlers for the same event type, one of them will be immediately overwritten.\n\n\n\n\n\n"
},

{
    "location": "client.html#Discord.delete_handler!",
    "page": "Client",
    "title": "Discord.delete_handler!",
    "category": "function",
    "text": "delete_handler!(c::Client, T::Type{<:AbstractEvent})\ndelete_handler!(c::Client, T::Type{<:AbstractEvent}, tag::Symbol)\n\nDelete event handlers. If no tag is supplied, all handlers for the event are deleted. Using the tagless method is generally not recommended because it also clears default handlers which maintain the client state. If you do want to delete a default handler, use DEFAULT_HANDLER_TAG.\n\n\n\n\n\n"
},

{
    "location": "client.html#Discord.DEFAULT_HANDLER_TAG",
    "page": "Client",
    "title": "Discord.DEFAULT_HANDLER_TAG",
    "category": "constant",
    "text": "Tag assigned to default handlers, which you can use to delete them.\n\n\n\n\n\n"
},

{
    "location": "client.html#Event-Handlers-1",
    "page": "Client",
    "title": "Event Handlers",
    "category": "section",
    "text": "See Events for more details.add_handler!\ndelete_handler!\nDEFAULT_HANDLER_TAG"
},

{
    "location": "client.html#Discord.add_command!",
    "page": "Client",
    "title": "Discord.add_command!",
    "category": "function",
    "text": "add_command!(\n    c::Client,\n    prefix::AbstractString,\n    func::Function;\n    tag::Symbol=gensym(),\n    expiry::Union{Int, Period, Nothing}=nothing,\n)\nadd_command!(\n    func::Function;\n    c::Client,\n    prefix::AbstractString,\n    tag::Symbol=gensym(),\n    expiry::Union{Int, Period, Nothing}=nothing,\n)\n\nAdd a text command handler. The handler function should take two arguments: A Client and a Message. The keyword arguments are identical to add_handler!. do syntax is also accepted.\n\n\n\n\n\n"
},

{
    "location": "client.html#Bot-Commands-1",
    "page": "Client",
    "title": "Bot Commands",
    "category": "section",
    "text": "add_command!"
},

{
    "location": "client.html#Discord.request_guild_members",
    "page": "Client",
    "title": "Discord.request_guild_members",
    "category": "function",
    "text": "request_guild_members(\n    c::Client,\n    guild_id::Union{Integer, Vector{<:Integer};\n    query::AbstractString=\"\",\n    limit::Int=0,\n) -> Bool\n\nRequest offline guild members of one or more guilds. GuildMembersChunk events are sent by the gateway in response. More details here.\n\n\n\n\n\n"
},

{
    "location": "client.html#Discord.update_voice_state",
    "page": "Client",
    "title": "Discord.update_voice_state",
    "category": "function",
    "text": "update_voice_state(\n    c::Client,\n    guild_id::Integer,\n    channel_id::Union{Integer, Nothing},\n    self_mute::Bool,\n    self_deaf::Bool,\n) -> Bool\n\nJoin, move, or disconnect from a voice channel. A VoiceStateUpdate event is sent by the gateway in response. More details here.\n\n\n\n\n\n"
},

{
    "location": "client.html#Discord.update_status",
    "page": "Client",
    "title": "Discord.update_status",
    "category": "function",
    "text": "update_status(\n    c::Client,\n    since::Union{Int, Nothing},\n    activity::Union{Activity, Nothing},\n    status::PresenceStatus,\n    afk::Bool,\n) -> Bool\n\nIndicate a presence or status update. A PresenceUpdate event is sent by the gateway in response. More details here.\n\n\n\n\n\n"
},

{
    "location": "client.html#Gateway-Commands-1",
    "page": "Client",
    "title": "Gateway Commands",
    "category": "section",
    "text": "request_guild_members\nupdate_voice_state\nupdate_status"
},

{
    "location": "client.html#Discord.enable_cache!",
    "page": "Client",
    "title": "Discord.enable_cache!",
    "category": "function",
    "text": "enable_cache!(c::Client)\nenable_cache!(f::Function c::Client)\n\nEnable the cache for REST operations.\n\n\n\n\n\n"
},

{
    "location": "client.html#Discord.disable_cache!",
    "page": "Client",
    "title": "Discord.disable_cache!",
    "category": "function",
    "text": "disable_cache!(c::Client)\ndisable_cache!(f::Function, c::Client)\n\nDisable the cache for REST operations.\n\n\n\n\n\n"
},

{
    "location": "client.html#Caching-1",
    "page": "Client",
    "title": "Caching",
    "category": "section",
    "text": "By default, most data that comes from Discord is cached for later use. However, to avoid memory leakage, some of it is deleted after some time. The default settings are to keep everything but Messages forever, but they can be overridden in the Client constructor. Although it\'s not recommended, you can disable caching of certain data by clearing default handlers for relevant event types with delete_handler! and DEFAULT_HANDLER_TAG. For example, if you wanted to avoid caching any messages at all, you would delete handlers for MessageCreate and MessageUpdate events. You can also enable and disable the cache with enable_cache! and disable_cache!, which both support do syntax for temporarily altering behaviour.enable_cache!\ndisable_cache!"
},

{
    "location": "client.html#Sharding-1",
    "page": "Client",
    "title": "Sharding",
    "category": "section",
    "text": "Sharding is handled automatically: The number of available processes is the number of shards that are created. See the sharding example for more details."
},

{
    "location": "events.html#",
    "page": "Events",
    "title": "Events",
    "category": "page",
    "text": "CurrentModule = Discord"
},

{
    "location": "events.html#Discord.AbstractEvent",
    "page": "Events",
    "title": "Discord.AbstractEvent",
    "category": "type",
    "text": "An incoming event sent over the gateway. Also a catch-all event: Handlers defined on this type will execute on all events, before the specific handlers run.\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.FallbackEvent",
    "page": "Events",
    "title": "Discord.FallbackEvent",
    "category": "type",
    "text": "A type for defining handlers on any events which would otherwise have no non-default handler. Handlers for this type must accept an AbstractEvent.\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.UnknownEvent",
    "page": "Events",
    "title": "Discord.UnknownEvent",
    "category": "type",
    "text": "An unknown event. When an event can\'t be parsed, due to an unknown type or any other error, it will appear as an UnknownEvent. The fields follow the schema defined here.\n\n\n\n\n\n"
},

{
    "location": "events.html#Events-1",
    "page": "Events",
    "title": "Events",
    "category": "section",
    "text": "Note that Snowflake === UInt64. Unions with Nothing indicate that a field is nullable, whereas Unions with Missing indicate that a field is optional. More details here.AbstractEvent\nFallbackEvent\nUnknownEvent"
},

{
    "location": "events.html#Discord.ChannelCreate",
    "page": "Events",
    "title": "Discord.ChannelCreate",
    "category": "type",
    "text": "Sent when a new DiscordChannel is created.\n\nFields\n\nchannel :: DiscordChannel\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.ChannelUpdate",
    "page": "Events",
    "title": "Discord.ChannelUpdate",
    "category": "type",
    "text": "Sent when a DiscordChannel is updated.\n\nFields\n\nchannel :: DiscordChannel\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.ChannelDelete",
    "page": "Events",
    "title": "Discord.ChannelDelete",
    "category": "type",
    "text": "Sent when a DiscordChannel is deleted.\n\nFields\n\nchannel :: DiscordChannel\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.ChannelPinsUpdate",
    "page": "Events",
    "title": "Discord.ChannelPinsUpdate",
    "category": "type",
    "text": "Sent when a DiscordChannel\'s pins are updated.\n\nFields\n\nchannel_id         :: UInt64\nlast_pin_timestamp :: Union{Nothing, DateTime}\n\n\n\n\n\n"
},

{
    "location": "events.html#Channels-1",
    "page": "Events",
    "title": "Channels",
    "category": "section",
    "text": "ChannelCreate\nChannelUpdate\nChannelDelete\nChannelPinsUpdate"
},

{
    "location": "events.html#Discord.GuildCreate",
    "page": "Events",
    "title": "Discord.GuildCreate",
    "category": "type",
    "text": "Sent when a new Guild is created.\n\nFields\n\nguild :: Guild\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.GuildUpdate",
    "page": "Events",
    "title": "Discord.GuildUpdate",
    "category": "type",
    "text": "Sent when a Guild is updated.\n\nFields\n\nguild :: Guild\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.GuildDelete",
    "page": "Events",
    "title": "Discord.GuildDelete",
    "category": "type",
    "text": "Sent when a Guild is deleted.\n\nFields\n\nguild :: AbstractGuild\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.GuildBanAdd",
    "page": "Events",
    "title": "Discord.GuildBanAdd",
    "category": "type",
    "text": "Sent when a User is banned from a Guild.\n\nFields\n\nguild_id :: UInt64\nuser     :: User\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.GuildBanRemove",
    "page": "Events",
    "title": "Discord.GuildBanRemove",
    "category": "type",
    "text": "Sent when a User is unbanned from a Guild.\n\nFields\n\nguild_id :: UInt64\nuser     :: User\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.GuildEmojisUpdate",
    "page": "Events",
    "title": "Discord.GuildEmojisUpdate",
    "category": "type",
    "text": "Sent when a Guild has its Emojis updated.\n\nFields\n\nguild_id :: UInt64\nemojis   :: Array{Emoji,1}\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.GuildIntegrationsUpdate",
    "page": "Events",
    "title": "Discord.GuildIntegrationsUpdate",
    "category": "type",
    "text": "Sent when a Guild has its Integrations updated.\n\nFields\n\nguild_id :: UInt64\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.GuildMemberAdd",
    "page": "Events",
    "title": "Discord.GuildMemberAdd",
    "category": "type",
    "text": "Sent when a Member is added to a Guild.\n\nFields\n\nguild_id :: UInt64\nmember   :: Member\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.GuildMemberRemove",
    "page": "Events",
    "title": "Discord.GuildMemberRemove",
    "category": "type",
    "text": "Sent when a Member is removed from a Guild.\n\nFields\n\nguild_id :: UInt64\nuser     :: User\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.GuildMemberUpdate",
    "page": "Events",
    "title": "Discord.GuildMemberUpdate",
    "category": "type",
    "text": "Sent when a Member is updated in a Guild.\n\nFields\n\nguild_id :: UInt64\nroles    :: Array{UInt64,1}\nuser     :: User\nnick     :: Union{Nothing, String}\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.GuildMembersChunk",
    "page": "Events",
    "title": "Discord.GuildMembersChunk",
    "category": "type",
    "text": "Sent when the Client requests guild members with request_guild_members.\n\nFields\n\nguild_id :: UInt64\nmembers  :: Array{Member,1}\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.GuildRoleCreate",
    "page": "Events",
    "title": "Discord.GuildRoleCreate",
    "category": "type",
    "text": "Sent when a new Role is created in a Guild.\n\nFields\n\nguild_id :: UInt64\nrole     :: Role\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.GuildRoleUpdate",
    "page": "Events",
    "title": "Discord.GuildRoleUpdate",
    "category": "type",
    "text": "Sent when a Role is updated in a Guild.\n\nFields\n\nguild_id :: UInt64\nrole     :: Role\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.GuildRoleDelete",
    "page": "Events",
    "title": "Discord.GuildRoleDelete",
    "category": "type",
    "text": "Sent when a Role is deleted from a Guild.\n\nFields\n\nguild_id :: UInt64\nrole_id  :: UInt64\n\n\n\n\n\n"
},

{
    "location": "events.html#Guilds-1",
    "page": "Events",
    "title": "Guilds",
    "category": "section",
    "text": "GuildCreate\nGuildUpdate\nGuildDelete\nGuildBanAdd\nGuildBanRemove\nGuildEmojisUpdate\nGuildIntegrationsUpdate\nGuildMemberAdd\nGuildMemberRemove\nGuildMemberUpdate\nGuildMembersChunk\nGuildRoleCreate\nGuildRoleUpdate\nGuildRoleDelete"
},

{
    "location": "events.html#Discord.MessageCreate",
    "page": "Events",
    "title": "Discord.MessageCreate",
    "category": "type",
    "text": "Sent when a Message is sent.\n\nFields\n\nmessage :: Message\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.MessageUpdate",
    "page": "Events",
    "title": "Discord.MessageUpdate",
    "category": "type",
    "text": "Sent when a Message is updated.\n\nFields\n\nmessage :: Message\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.MessageDelete",
    "page": "Events",
    "title": "Discord.MessageDelete",
    "category": "type",
    "text": "Sent when a Message is deleted.\n\nFields\n\nid         :: UInt64\nchannel_id :: UInt64\nguild_id   :: Union{Missing, UInt64}\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.MessageDeleteBulk",
    "page": "Events",
    "title": "Discord.MessageDeleteBulk",
    "category": "type",
    "text": "Sent when multiple Messages are deleted in bulk.\n\nFields\n\nids        :: Array{UInt64,1}\nchannel_id :: UInt64\nguild_id   :: Union{Missing, UInt64}\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.MessageReactionAdd",
    "page": "Events",
    "title": "Discord.MessageReactionAdd",
    "category": "type",
    "text": "Sent when a Reaction is added to a Message.\n\nFields\n\nuser_id    :: UInt64\nchannel_id :: UInt64\nmessage_id :: UInt64\nguild_id   :: Union{Missing, UInt64}\nemoji      :: Emoji\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.MessageReactionRemove",
    "page": "Events",
    "title": "Discord.MessageReactionRemove",
    "category": "type",
    "text": "Sent when a Reaction is removed from a Message.\n\nFields\n\nuser_id    :: UInt64\nchannel_id :: UInt64\nmessage_id :: UInt64\nguild_id   :: Union{Missing, UInt64}\nemoji      :: Emoji\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.MessageReactionRemoveAll",
    "page": "Events",
    "title": "Discord.MessageReactionRemoveAll",
    "category": "type",
    "text": "Sent when all Reactions are removed from a Message.\n\nFields\n\nchannel_id :: UInt64\nmessage_id :: UInt64\nguild_id   :: Union{Missing, UInt64}\n\n\n\n\n\n"
},

{
    "location": "events.html#Messages-1",
    "page": "Events",
    "title": "Messages",
    "category": "section",
    "text": "MessageCreate\nMessageUpdate\nMessageDelete\nMessageDeleteBulk\nMessageReactionAdd\nMessageReactionRemove\nMessageReactionRemoveAll"
},

{
    "location": "events.html#Discord.PresenceUpdate",
    "page": "Events",
    "title": "Discord.PresenceUpdate",
    "category": "type",
    "text": "Sent when a User\'s Presence is updated.\n\nFields\n\npresence :: Presence\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.TypingStart",
    "page": "Events",
    "title": "Discord.TypingStart",
    "category": "type",
    "text": "Sent when a User begins typing.\n\nFields\n\nchannel_id :: UInt64\nguild_id   :: Union{Missing, UInt64}\nuser_id    :: UInt64\ntimestamp  :: Dates.DateTime\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.UserUpdate",
    "page": "Events",
    "title": "Discord.UserUpdate",
    "category": "type",
    "text": "Sent when a User\'s details are updated.\n\nFields\n\nuser :: User\n\n\n\n\n\n"
},

{
    "location": "events.html#Presence-1",
    "page": "Events",
    "title": "Presence",
    "category": "section",
    "text": "PresenceUpdate\nTypingStart\nUserUpdate"
},

{
    "location": "events.html#Discord.VoiceStateUpdate",
    "page": "Events",
    "title": "Discord.VoiceStateUpdate",
    "category": "type",
    "text": "Sent when a User updates their VoiceState.\n\nFields\n\nstate :: VoiceState\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.VoiceServerUpdate",
    "page": "Events",
    "title": "Discord.VoiceServerUpdate",
    "category": "type",
    "text": "Sent when a Guild\'s voice server is updated.\n\nFields\n\ntoken    :: String\nguild_id :: UInt64\nendpoint :: String\n\n\n\n\n\n"
},

{
    "location": "events.html#Voice-1",
    "page": "Events",
    "title": "Voice",
    "category": "section",
    "text": "VoiceStateUpdate\nVoiceServerUpdate"
},

{
    "location": "events.html#Discord.WebhooksUpdate",
    "page": "Events",
    "title": "Discord.WebhooksUpdate",
    "category": "type",
    "text": "Sent when a DiscordChannel\'s Webhooks are updated.\n\nFields\n\nguild_id   :: UInt64\nchannel_id :: UInt64\n\n\n\n\n\n"
},

{
    "location": "events.html#Webhooks-1",
    "page": "Events",
    "title": "Webhooks",
    "category": "section",
    "text": "WebhooksUpdate"
},

{
    "location": "events.html#Discord.Ready",
    "page": "Events",
    "title": "Discord.Ready",
    "category": "type",
    "text": "Sent when the Client has authenticated, and contains the initial state.\n\nFields\n\nv                :: Int64\nuser             :: User\nprivate_channels :: Array{DiscordChannel,1}\nguilds           :: Array{UnavailableGuild,1}\nsession_id       :: String\n_trace           :: Array{String,1}\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.Resumed",
    "page": "Events",
    "title": "Discord.Resumed",
    "category": "type",
    "text": "Sent when a Client resumes its connection.\n\nFields\n\n_trace :: Array{String,1}\n\n\n\n\n\n"
},

{
    "location": "events.html#Connecting-1",
    "page": "Events",
    "title": "Connecting",
    "category": "section",
    "text": "Ready\nResumed"
},

{
    "location": "rest.html#",
    "page": "REST API",
    "title": "REST API",
    "category": "page",
    "text": "CurrentModule = Discord"
},

{
    "location": "rest.html#REST-API-1",
    "page": "REST API",
    "title": "REST API",
    "category": "section",
    "text": ""
},

{
    "location": "rest.html#Discord.Response",
    "page": "REST API",
    "title": "Discord.Response",
    "category": "type",
    "text": "A wrapper around a response from the REST API. Every function which wraps a Discord REST API endpoint returns a Future which will contain a value of this type. To retrieve the Response from the Future, use fetch or fetchval.\n\nFields\n\nval::Union{T, Nothing}: The object contained in the HTTP response. For example, for a call to get_channel_message, this value will be a Message.\nok::Bool: The state of the request. If true, then it is safe to access val.\nhttp_response::Union{HTTP.Messages.Response, Nothing}: The underlying HTTP response, if a request was made.\nexception::Union{Exception, Nothing}: The caught exception, if one is thrown.\n\nExample\n\njulia> using Discord; c = Client(\"token\"); ch = 1234567890;\n\njulia> fs = map(i -> Discord.create_message(c, ch; content=string(i)), 1:10);\n\njulia> typeof(first(fs))\nDistributed.Future\n\njulia> typeof(fetch(first(fs)))\nDiscord.Response{Message}\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.fetchval",
    "page": "REST API",
    "title": "Discord.fetchval",
    "category": "function",
    "text": "fetchval(f::Future{Response{T}}) -> Union{T, Nothing}\n\nShortcut for fetch(f).val: Fetch a Response and return its value. Note that there are no guarantees about the response\'s success and the value being returned, and it discards context that can be useful for debugging, such as HTTP responses and caught exceptions.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Response-1",
    "page": "REST API",
    "title": "Response",
    "category": "section",
    "text": "Response\nfetchval"
},

{
    "location": "rest.html#Discord.create",
    "page": "REST API",
    "title": "Discord.create",
    "category": "function",
    "text": "create(c::Client, ::Type{T}, args...; kwargs...)\n\nCreate, add, send, etc.\n\nExamples\n\n# Send a message.\njulia> create(c, Message, channel; content=\"foo\")\n\n# Create a new channel.\njulia> create(c, DiscordChannel, guild; name=\"bar\")\n\n# Ban a user.\njulia> create(c, Ban, guild, user; reason=\"baz\")\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.retrieve",
    "page": "REST API",
    "title": "Discord.retrieve",
    "category": "function",
    "text": "retrieve(c::Client, ::Type{T}, args...; kwargs...)\n\nRetreive, get, list, etc.\n\nExamples\n\n# Get the client user.\njulia> retrieve(c, User)\n\n# Get a guild\'s channels.\njulia> retrieve(c, DiscordChannel, guild)\n\n# Get an invite to a guild by code.\njulia> retrieve(c, Invite, \"abcdef\")\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.update",
    "page": "REST API",
    "title": "Discord.update",
    "category": "function",
    "text": "update(c::Client, x::T, args...; kwargs...)\n\nUpdate, edit, modify, etc.\n\nExamples\n\n# Edit a message.\njulia> update(c, message; content=\"foo2\")\n\n# Modify a webhook.\njulia> update(c, webhook; name=\"bar2\")\n\n# Update a role.\njulia> update(c, role, guild; permissions=8)\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.delete",
    "page": "REST API",
    "title": "Discord.delete",
    "category": "function",
    "text": "delete(c::Client, x::T, args...)\n\nDelete, remove, discard, etc.\n\nExamples\n\n# Kick a user from a guild.\njulia> delete(c, member)\n\n# Unban a user from a guild.\njulia> delete(c, ban, guild)\n\n# Delete all reactions on a message.\n# This is the only update/delete method which takes a type parameter.\ndelete(c, Reaction, message)\n\n\n\n\n\n"
},

{
    "location": "rest.html#CRUD-API-1",
    "page": "REST API",
    "title": "CRUD API",
    "category": "section",
    "text": "On top of functions for accessing individual endpoints such as get_channel_messages, Discord.jl also offers a unified API with just four functions. Named after the CRUD model, they cover most of the Discord REST API and allow you to write concise, expressive code, and forget about the subtleties of endpoint naming. The argument ordering convention is roughly as follows:A Client, always.\nFor cases when we don\'t yet have the entity to be manipulated (usually create and retrieve), the entity\'s type. If we do have the entity (update and delete), the entity itself.\nThe remaining positional arguments supply whatever context is needed to specify the entity. For example, sending a message requires a DiscordChannel parameter.\nKeyword arguments follow (usually for create and update).create\nretrieve\nupdate\ndeleteThe full list of types available to be manipulated is:AuditLog\nBan\nDiscordChannel\nEmoji\nGuildEmbed\nGuild\nIntegration\nInvite\nMember\nMessage\nOverwrite\nReaction\nRole\nUser\nVoiceRegion\nWebhook"
},

{
    "location": "rest.html#Endpoints-1",
    "page": "REST API",
    "title": "Endpoints",
    "category": "section",
    "text": "Functions which wrap REST API endpoints are named and sorted according to the Discord API documentation. When a function accepts keyword arguments, the docstring will include a link to the Discord documentation which indicates the expected keys and values. Remember that the return types annotated below are not the actual return types, but the types of Response that the returned Futures will yield."
},

{
    "location": "rest.html#Discord.get_guild_audit_log",
    "page": "REST API",
    "title": "Discord.get_guild_audit_log",
    "category": "function",
    "text": "get_guild_audit_log(c::Client, guild::Integer; kwargs...) -> AuditLog\n\nGet a Guild\'s AuditLog. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Audit-Log-1",
    "page": "REST API",
    "title": "Audit Log",
    "category": "section",
    "text": "get_guild_audit_log"
},

{
    "location": "rest.html#Discord.get_channel",
    "page": "REST API",
    "title": "Discord.get_channel",
    "category": "function",
    "text": "get_channel(c::Client, channel::Integer) -> DiscordChannel\n\nGet a DiscordChannel.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.modify_channel",
    "page": "REST API",
    "title": "Discord.modify_channel",
    "category": "function",
    "text": "modify_channel(c::Client, channel::Integer; kwargs...) -> DiscordChannel\n\nModify a DiscordChannel. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.delete_channel",
    "page": "REST API",
    "title": "Discord.delete_channel",
    "category": "function",
    "text": "delete_channel(c::Client, channel::Integer) -> DiscordChannel\n\nDelete a DiscordChannel.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.get_channel_messages",
    "page": "REST API",
    "title": "Discord.get_channel_messages",
    "category": "function",
    "text": "get_channel_messages(c::Client, channel::Integer; kwargs...) -> Vector{Message}\n\nGet a list of Messages from a DiscordChannel. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.get_channel_message",
    "page": "REST API",
    "title": "Discord.get_channel_message",
    "category": "function",
    "text": "get_channel_message(c::Client, channel::Integer, message::Integer) -> Message\n\nGet a Message from a DiscordChannel.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.create_message",
    "page": "REST API",
    "title": "Discord.create_message",
    "category": "function",
    "text": "create_message(c::Client, channel::Integer; kwargs...) -> Message\n\nSend a Message to a DiscordChannel. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.create_reaction",
    "page": "REST API",
    "title": "Discord.create_reaction",
    "category": "function",
    "text": "create_reaction(\n    c::Client,\n    channel::Integer,\n    message::Integer,\n    emoji::Union{AbstractString, AbstractChar},\n)\n\nReact to a Message.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.delete_own_reaction",
    "page": "REST API",
    "title": "Discord.delete_own_reaction",
    "category": "function",
    "text": "delete_own_reaction(\n    c::Client,\n    channel::Integer,\n    message::Integer,\n    emoji::Union{AbstractString, AbstractChar},\n)\n\nDelete the Client user\'s reaction to a Message.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.delete_user_reaction",
    "page": "REST API",
    "title": "Discord.delete_user_reaction",
    "category": "function",
    "text": "delete_user_reaction(\n    c::Client,\n    channel::Integer,\n    message::Integer,\n    emoji::Union{AbstractString, AbstractChar},\n    user::Integer,\n)\n\nDelete a User\'s reaction to a Message.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.get_reactions",
    "page": "REST API",
    "title": "Discord.get_reactions",
    "category": "function",
    "text": "get_reactions(\n    c::Client,\n    channel::Integer,\n    message::Integer,\n    emoji::Union{AbstractString, AbstractChar},\n) -> Vector{User}\n\nGet the Users who reacted to a Message with an Emoji.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.delete_all_reactions",
    "page": "REST API",
    "title": "Discord.delete_all_reactions",
    "category": "function",
    "text": "delete_all_reactions(c::Client, channel::Integer, message::Integer)\n\nDelete all reactions from a Message.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.edit_message",
    "page": "REST API",
    "title": "Discord.edit_message",
    "category": "function",
    "text": "edit_message(c::Client, channel::Integer, message::Integer; kwargs...) -> Message\n\nEdit a Message. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.delete_message",
    "page": "REST API",
    "title": "Discord.delete_message",
    "category": "function",
    "text": "delete_message(c::Client, channel::Integer, message::Integer)\n\nDelete a Message.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.bulk_delete_messages",
    "page": "REST API",
    "title": "Discord.bulk_delete_messages",
    "category": "function",
    "text": "bulk_delete_messages(c::Client, channel::Integer; kwargs...)\n\nDelete multiple Messages. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.edit_channel_permissions",
    "page": "REST API",
    "title": "Discord.edit_channel_permissions",
    "category": "function",
    "text": "edit_channel_permissions(\n    c::Client,\n    channel::Integer,\n    overwrite::Integer;\n    kwargs...,\n)\n\nEdit permissions for a DiscordChannel. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.get_channel_invites",
    "page": "REST API",
    "title": "Discord.get_channel_invites",
    "category": "function",
    "text": "get_channel_invites(c::Client, channel::Integer) -> Vector{Invite}\n\nGet the Invites for a DiscordChannel.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.create_channel_invite",
    "page": "REST API",
    "title": "Discord.create_channel_invite",
    "category": "function",
    "text": "create_channel_invite(c::Client, channel::Integer; kwargs...) -> Invite\n\nCreate an Invite to a DiscordChannel. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.delete_channel_permission",
    "page": "REST API",
    "title": "Discord.delete_channel_permission",
    "category": "function",
    "text": "delete_channel_permission(c::Client, channel::Integer, overwrite::Integer)\n\nDelete an Overwrite from a DiscordChannel.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.trigger_typing_indicator",
    "page": "REST API",
    "title": "Discord.trigger_typing_indicator",
    "category": "function",
    "text": "trigger_typing_indicator(c::Client, channel::Integer)\n\nTrigger the typing indicator in a DiscordChannel.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.get_pinned_messages",
    "page": "REST API",
    "title": "Discord.get_pinned_messages",
    "category": "function",
    "text": "get_pinned_messages(c::Client, channel::Integer) -> Vector{Message}\n\nGet the pinned Messages in a DiscordChannel.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.add_pinned_channel_message",
    "page": "REST API",
    "title": "Discord.add_pinned_channel_message",
    "category": "function",
    "text": "add_pinned_channel_message(c::Client, channel::Integer, message::Integer)\n\nPin a Message in a DiscordChannel.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.delete_pinned_channel_message",
    "page": "REST API",
    "title": "Discord.delete_pinned_channel_message",
    "category": "function",
    "text": "delete_pinned_channel_message(c::Client, channel::Integer, message::Integer)\n\nUnpin a Message from a DiscordChannel.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.group_dm_add_recipient",
    "page": "REST API",
    "title": "Discord.group_dm_add_recipient",
    "category": "function",
    "text": "group_dm_add_recipient(c::Client, channel::Integer, user::Integer; kwargs...)\n\nAdd a User to a group DM. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.group_dm_remove_recipient",
    "page": "REST API",
    "title": "Discord.group_dm_remove_recipient",
    "category": "function",
    "text": "group_dm_remove_recipient(c::Client, channel::Integer, user::Integer)\n\nRemove a User from a group DM.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Channel-1",
    "page": "REST API",
    "title": "Channel",
    "category": "section",
    "text": "get_channel\nmodify_channel\ndelete_channel\nget_channel_messages\nget_channel_message\ncreate_message\ncreate_reaction\ndelete_own_reaction\ndelete_user_reaction\nget_reactions\ndelete_all_reactions\nedit_message\ndelete_message\nbulk_delete_messages\nedit_channel_permissions\nget_channel_invites\ncreate_channel_invite\ndelete_channel_permission\ntrigger_typing_indicator\nget_pinned_messages\nadd_pinned_channel_message\ndelete_pinned_channel_message\ngroup_dm_add_recipient\ngroup_dm_remove_recipient"
},

{
    "location": "rest.html#Discord.list_guild_emojis",
    "page": "REST API",
    "title": "Discord.list_guild_emojis",
    "category": "function",
    "text": "list_guild_emojis(c::Client, guild::Integer) -> Vector{Emoji}\n\nGet the Emojis in a Guild.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.get_guild_emoji",
    "page": "REST API",
    "title": "Discord.get_guild_emoji",
    "category": "function",
    "text": "get_guild_emoji(c::Client, guild::Integer, emoji::Integer) -> Emoji\n\nGet an Emoji in a Guild.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.create_guild_emoji",
    "page": "REST API",
    "title": "Discord.create_guild_emoji",
    "category": "function",
    "text": "create_guild_emoji(c::Client, guild::Integer; kwargs...) -> Emoji\n\nCreate an Emoji in a Guild. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.modify_guild_emoji",
    "page": "REST API",
    "title": "Discord.modify_guild_emoji",
    "category": "function",
    "text": "modify_guild_emoji(c::Client, guild::Integer, emoji::Integer; kwargs...) -> Emoji\n\nEdit an Emoji in a Guild. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.delete_guild_emoji",
    "page": "REST API",
    "title": "Discord.delete_guild_emoji",
    "category": "function",
    "text": "delete_guild_emoji(c::Client, guild::Integer, emoji::Integer)\n\nDelete an Emoji from a Guild.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Emoji-1",
    "page": "REST API",
    "title": "Emoji",
    "category": "section",
    "text": "list_guild_emojis\nget_guild_emoji\ncreate_guild_emoji\nmodify_guild_emoji\ndelete_guild_emoji"
},

{
    "location": "rest.html#Discord.create_guild",
    "page": "REST API",
    "title": "Discord.create_guild",
    "category": "function",
    "text": "create_guild(c::Client; kwargs...) -> Guild\n\nCreate a Guild. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.get_guild",
    "page": "REST API",
    "title": "Discord.get_guild",
    "category": "function",
    "text": "get_guild(c::Client, guild::Integer) -> Guild\n\nGet a Guild.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.modify_guild",
    "page": "REST API",
    "title": "Discord.modify_guild",
    "category": "function",
    "text": "modify_guild(c::Client, guild::Integer; kwargs...) -> Guild\n\nEdit a Guild. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.delete_guild",
    "page": "REST API",
    "title": "Discord.delete_guild",
    "category": "function",
    "text": "delete_guild(c::Client, guild::Integer)\n\nDelete a Guild.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.get_guild_channels",
    "page": "REST API",
    "title": "Discord.get_guild_channels",
    "category": "function",
    "text": "get_guild_channels(c::Client, guild::Integer) -> Vector{DiscordChannel}\n\nGet the DiscordChannels in a Guild.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.create_guild_channel",
    "page": "REST API",
    "title": "Discord.create_guild_channel",
    "category": "function",
    "text": "create_guild_channel(c::Client, guild::Integer; kwargs...) -> DiscordChannel\n\nCreate a DiscordChannel in a Guild. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.modify_guild_channel_positions",
    "page": "REST API",
    "title": "Discord.modify_guild_channel_positions",
    "category": "function",
    "text": "modify_guild_channel_positions(c::Client, guild::Integer, positions...)\n\nModify the positions of DiscordChannels in a Guild. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.get_guild_member",
    "page": "REST API",
    "title": "Discord.get_guild_member",
    "category": "function",
    "text": "get_guild_member(c::Client, guild::Integer, user::Integer) -> Member\n\nGet a Member in a Guild.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.list_guild_members",
    "page": "REST API",
    "title": "Discord.list_guild_members",
    "category": "function",
    "text": "list_guild_members(c::Client, guild::Integer; kwargs...) -> Vector{Member}\n\nGet a list of Members in a Guild. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.add_guild_member",
    "page": "REST API",
    "title": "Discord.add_guild_member",
    "category": "function",
    "text": "add_guild_member(c::Client; kwargs...) -> Member\n\nAdd a User to a Guild. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.modify_guild_member",
    "page": "REST API",
    "title": "Discord.modify_guild_member",
    "category": "function",
    "text": "modify_guild__member(c::Client, guild::Integer, user::Integer; kwargs...)\n\nModify a Member in a Guild. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.modify_current_user_nick",
    "page": "REST API",
    "title": "Discord.modify_current_user_nick",
    "category": "function",
    "text": "modify_current_user_nick(c::Client, guild::Intger; kwargs...) -> String\n\nModify the Client user\'s nickname in a Guild. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.add_guild_member_role",
    "page": "REST API",
    "title": "Discord.add_guild_member_role",
    "category": "function",
    "text": "add_guild_member_role(c::Client, guild::Integer, user::Integer, role::Integer)\n\nAdd a Role to a Member.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.remove_guild_member_role",
    "page": "REST API",
    "title": "Discord.remove_guild_member_role",
    "category": "function",
    "text": "remove_guild_member_role(c::Client, guild::Integer, user::Integer, role::Integer)\n\nRemove a Role from a Member.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.remove_guild_member",
    "page": "REST API",
    "title": "Discord.remove_guild_member",
    "category": "function",
    "text": "remove_guild_member(c::Client, guild::Integer, user::Integer)\n\nKick a Member from a Guild.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.get_guild_bans",
    "page": "REST API",
    "title": "Discord.get_guild_bans",
    "category": "function",
    "text": "get_guild_bans(c::Client, guild::Integer) -> Vector{Ban}\n\nGet a list of Bans in a Guild.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.get_guild_ban",
    "page": "REST API",
    "title": "Discord.get_guild_ban",
    "category": "function",
    "text": "get_ban(c::Client, guild::Integer,  user::Integer) -> Ban\n\nGet a Ban in a Guild.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.create_guild_ban",
    "page": "REST API",
    "title": "Discord.create_guild_ban",
    "category": "function",
    "text": "create_guild_ban(c::Client, guild::Integer, user::Integer; kwargs...)\n\nBan a Member from a Guild. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.remove_guild_ban",
    "page": "REST API",
    "title": "Discord.remove_guild_ban",
    "category": "function",
    "text": "remove_guild_ban(c::Client, guild::Integer, user::Integer)\n\nUnban a User from a Guild.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.get_guild_roles",
    "page": "REST API",
    "title": "Discord.get_guild_roles",
    "category": "function",
    "text": "get_guild_roles(c::Client, guild::Integer) -> Vector{Role}\n\nGet a Guild\'s Roles.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.create_guild_role",
    "page": "REST API",
    "title": "Discord.create_guild_role",
    "category": "function",
    "text": "create_guild_role(c::Client, guild::Integer; kwargs) -> Role\n\nCreate a Role in a Guild. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.modify_guild_role_positions",
    "page": "REST API",
    "title": "Discord.modify_guild_role_positions",
    "category": "function",
    "text": "modify_guild_role_positions(c::Client, guild::Integer, positions...) -> Vector{Role}\n\nModify the positions of Roles in a Guild. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.modify_guild_role",
    "page": "REST API",
    "title": "Discord.modify_guild_role",
    "category": "function",
    "text": "modify_guild_role(c::Client, guild::Integer, role::Integer; kwargs) -> Role\n\nModify a Role in a Guild. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.delete_guild_role",
    "page": "REST API",
    "title": "Discord.delete_guild_role",
    "category": "function",
    "text": "delete_guild_role(c::Client, guild::Integer, role::Integer)\n\nDelete a Role from a Guild.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.get_guild_prune_count",
    "page": "REST API",
    "title": "Discord.get_guild_prune_count",
    "category": "function",
    "text": "get_guild_prune_count(c::Client, guild::Integer; kwargs...) -> Dict\n\nGet the number of Members that would be removed from a Guild in a prune. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.begin_guild_prune",
    "page": "REST API",
    "title": "Discord.begin_guild_prune",
    "category": "function",
    "text": "begin_guild_prune(c::Client, guild::Integer; kwargs...) -> Dict\n\nBegin pruning Members from a Guild. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.get_guild_voice_regions",
    "page": "REST API",
    "title": "Discord.get_guild_voice_regions",
    "category": "function",
    "text": "get_guild_voice_regions(c::Client, guild::Integer) -> Vector{VoiceRegion}\n\nGet a list of VoiceRegions for the Guild.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.get_guild_invites",
    "page": "REST API",
    "title": "Discord.get_guild_invites",
    "category": "function",
    "text": "get_guild_invites(c::Client, guild::Integer) -> Vector{Invite}\n\nGet a list of Invites to a Guild.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.get_guild_integrations",
    "page": "REST API",
    "title": "Discord.get_guild_integrations",
    "category": "function",
    "text": "get_guild_integrations(c::Client, guild::Integer) -> Vector{Integration}\n\nGet a list of Integrations for a Guild.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.create_guild_integration",
    "page": "REST API",
    "title": "Discord.create_guild_integration",
    "category": "function",
    "text": "create_guild_integration(c::Client, guild::Integer; kwargs...)\n\nCreate/attach an Integration to a Guild. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.modify_guild_integration",
    "page": "REST API",
    "title": "Discord.modify_guild_integration",
    "category": "function",
    "text": "modify_guild_integration(c::Client, guild::Integer, integration::Integer; kwargs...)\n\nModify an Integration in a Guild. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.delete_guild_integration",
    "page": "REST API",
    "title": "Discord.delete_guild_integration",
    "category": "function",
    "text": "delete_guild_integration(c::Client, guild::Integer, integration::Integer)\n\nDelete an Integration from a Guild.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.sync_guild_integration",
    "page": "REST API",
    "title": "Discord.sync_guild_integration",
    "category": "function",
    "text": "sync_guild_integration(c::Client, guild::Integer, integration::Integer)\n\nSync an Integration in a Guild.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.get_guild_embed",
    "page": "REST API",
    "title": "Discord.get_guild_embed",
    "category": "function",
    "text": "get_guild_embed(c::Client, guild::Integer) -> GuildEmbed\n\nGet a Guild\'s GuildEmbed.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.modify_guild_embed",
    "page": "REST API",
    "title": "Discord.modify_guild_embed",
    "category": "function",
    "text": "modify_guild_embed(c::Client, guild::Integer; kwargs...) -> GuildEmbed\n\nModify a Guild\'s GuildEmbed. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.get_vanity_url",
    "page": "REST API",
    "title": "Discord.get_vanity_url",
    "category": "function",
    "text": "get_vanity_url(c::Client, guild::Integer) -> Invite\n\nGet a Guild\'s vanity URL, if it supports that feature.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.get_guild_widget_image",
    "page": "REST API",
    "title": "Discord.get_guild_widget_image",
    "category": "function",
    "text": "get_guild_widget_image(c::Client, guild::Integer; kwargs...) -> Vector{UInt8}\n\nGet a Guild\'s widget image in PNG format. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Guild-1",
    "page": "REST API",
    "title": "Guild",
    "category": "section",
    "text": "create_guild\nget_guild\nmodify_guild\ndelete_guild\nget_guild_channels\ncreate_guild_channel\nmodify_guild_channel_positions\nget_guild_member\nlist_guild_members\nadd_guild_member\nmodify_guild_member\nmodify_current_user_nick\nadd_guild_member_role\nremove_guild_member_role\nremove_guild_member\nget_guild_bans\nget_guild_ban\ncreate_guild_ban\nremove_guild_ban\nget_guild_roles\ncreate_guild_role\nmodify_guild_role_positions\nmodify_guild_role\ndelete_guild_role\nget_guild_prune_count\nbegin_guild_prune\nget_guild_voice_regions\nget_guild_invites\nget_guild_integrations\ncreate_guild_integration\nmodify_guild_integration\ndelete_guild_integration\nsync_guild_integration\nget_guild_embed\nmodify_guild_embed\nget_vanity_url\nget_guild_widget_image"
},

{
    "location": "rest.html#Discord.get_invite",
    "page": "REST API",
    "title": "Discord.get_invite",
    "category": "function",
    "text": "get_invite(c::Client, invite::AbstractString; kwargs...} -> Invite\n\nGet an Invite to a Guild. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.delete_invite",
    "page": "REST API",
    "title": "Discord.delete_invite",
    "category": "function",
    "text": "delete_invite(c::Client, invite::AbstractString) -> Invite\n\nDelete an Invite to a Guild.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Invite-1",
    "page": "REST API",
    "title": "Invite",
    "category": "section",
    "text": "get_invite\ndelete_invite"
},

{
    "location": "rest.html#Discord.get_current_user",
    "page": "REST API",
    "title": "Discord.get_current_user",
    "category": "function",
    "text": "get_current_user(c::Client) -> User\n\nGet the Client User.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.get_user",
    "page": "REST API",
    "title": "Discord.get_user",
    "category": "function",
    "text": "get_user(c::Client, user::Integer) -> User\n\nGet a User.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.modify_current_user",
    "page": "REST API",
    "title": "Discord.modify_current_user",
    "category": "function",
    "text": "modify_current_user(c::Client; kwargs...) -> User\n\nModify the Client User. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.get_current_user_guilds",
    "page": "REST API",
    "title": "Discord.get_current_user_guilds",
    "category": "function",
    "text": "get_user_guilds(c::Client; kwargs...) -> Vector{Guild}\n\nGet a list of Guilds the Client User is a member of. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.leave_guild",
    "page": "REST API",
    "title": "Discord.leave_guild",
    "category": "function",
    "text": "leave_guild(c::Client, guild::Integer)\n\nLeave a Guild.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.create_dm",
    "page": "REST API",
    "title": "Discord.create_dm",
    "category": "function",
    "text": "create_dm(c::Client; kwargs...) -> DiscordChannel\n\nCreate a DM DiscordChannel. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.create_group_dm",
    "page": "REST API",
    "title": "Discord.create_group_dm",
    "category": "function",
    "text": "create_group_dm(c::Client; kwargs...) -> DiscordChannel\n\nCreate a group DM DiscordChannel. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#User-1",
    "page": "REST API",
    "title": "User",
    "category": "section",
    "text": "get_current_user\nget_user\nmodify_current_user\nget_current_user_guilds\nleave_guild\ncreate_dm\ncreate_group_dm"
},

{
    "location": "rest.html#Discord.list_voice_regions",
    "page": "REST API",
    "title": "Discord.list_voice_regions",
    "category": "function",
    "text": "list_voice_regions(c::Client) -> Vector{VoiceRegion}\n\nGet a list of the VoiceRegions that can be used when creating Guilds.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Voice-1",
    "page": "REST API",
    "title": "Voice",
    "category": "section",
    "text": "list_voice_regions"
},

{
    "location": "rest.html#Discord.create_webhook",
    "page": "REST API",
    "title": "Discord.create_webhook",
    "category": "function",
    "text": "create_webhook(c::Client, channel::Integer; kwargs...) -> Webhook\n\nCreate a Webhook in a DiscordChannel. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.get_channel_webhooks",
    "page": "REST API",
    "title": "Discord.get_channel_webhooks",
    "category": "function",
    "text": "get_channel_webhooks(c::Client, channel::Integer) -> Vector{Webhook}\n\nGet a list of Webhooks in a DiscordChannel.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.get_guild_webhooks",
    "page": "REST API",
    "title": "Discord.get_guild_webhooks",
    "category": "function",
    "text": "get_guild_webhooks(c::Client, guild::Integer) -> Vector{Webhook}\n\nGet a list of Webhooks in a Guild.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.get_webhook",
    "page": "REST API",
    "title": "Discord.get_webhook",
    "category": "function",
    "text": "get_webhook(c::Client, webhook::Integer) -> Webhook\n\nGet a Webhook.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.get_webhook_with_token",
    "page": "REST API",
    "title": "Discord.get_webhook_with_token",
    "category": "function",
    "text": "get_webhook_with_token(c::Client, webhook::Integer, token::AbstractString) -> Webhook\n\nGet a Webhook with a token.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.modify_webhook",
    "page": "REST API",
    "title": "Discord.modify_webhook",
    "category": "function",
    "text": "modify_webhook(c::Client, webhook::Integer; kwargs...) -> Webhook\n\nModify a Webhook. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.modify_webhook_with_token",
    "page": "REST API",
    "title": "Discord.modify_webhook_with_token",
    "category": "function",
    "text": "modify_webhook_with_token(\n    c::Client,\n    webhook::Integer,\n    token::AbstractString;\n    kwargs...,\n) -> Webhook\n\nModify a Webhook with a token. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.delete_webhook",
    "page": "REST API",
    "title": "Discord.delete_webhook",
    "category": "function",
    "text": "delete_webhook(c::Client, webhook::Integer)\n\nDelete a Webhook.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.delete_webhook_with_token",
    "page": "REST API",
    "title": "Discord.delete_webhook_with_token",
    "category": "function",
    "text": "delete_webhook_with_token(c::Client, webhook::Integer, token::AbstractString)\n\nDelete a Webhook with a token.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.execute_webhook",
    "page": "REST API",
    "title": "Discord.execute_webhook",
    "category": "function",
    "text": "execute_webhook(\n    c::Client,\n    webhook::Integer,\n    token::AbstractString;\n    wait::Bool=false,\n    kwargs...,\n) -> Message\n\nExecute a Webhook. If wait is not set, no Message is returned. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.execute_slack_compatible_webhook",
    "page": "REST API",
    "title": "Discord.execute_slack_compatible_webhook",
    "category": "function",
    "text": "execute_slack_compatible_webhook(\n    c::Client,\n    webhook::Integer,\n    token::AbstractString;\n    wait::Bool=true,\n    kwargs...,\n)\n\nExecute a Slack Webhook. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Discord.execute_github_compatible_webhook",
    "page": "REST API",
    "title": "Discord.execute_github_compatible_webhook",
    "category": "function",
    "text": "execute_github_compatible_webhook(\n    c::Client,\n    webhook::Integer,\n    token::AbstractString;\n    wait::Bool=true,\n    kwargs...,\n)\n\nExecute a Github Webhook. More details here.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Webhook-1",
    "page": "REST API",
    "title": "Webhook",
    "category": "section",
    "text": "create_webhook\nget_channel_webhooks\nget_guild_webhooks\nget_webhook\nget_webhook_with_token\nmodify_webhook\nmodify_webhook_with_token\ndelete_webhook\ndelete_webhook_with_token\nexecute_webhook\nexecute_slack_compatible_webhook\nexecute_github_compatible_webhook"
},

{
    "location": "helpers.html#",
    "page": "Helpers",
    "title": "Helpers",
    "category": "page",
    "text": "CurrentModule = Discord"
},

{
    "location": "helpers.html#Discord.reply",
    "page": "Helpers",
    "title": "Discord.reply",
    "category": "function",
    "text": "reply(c::Client, m::Message, content::AbstractString; at::Bool=false)\n\nReply (send a message to the same DiscordChannel) to a Message. If at is set, then the message is prefixed with the sender\'s mention.\n\n\n\n\n\n"
},

{
    "location": "helpers.html#Discord.mention",
    "page": "Helpers",
    "title": "Discord.mention",
    "category": "function",
    "text": "mention(x::Union{DiscordChannel, Member, Role, User}) -> String\n\nGet the mention string for an entity.\n\n\n\n\n\n"
},

{
    "location": "helpers.html#Discord.replace_mentions",
    "page": "Helpers",
    "title": "Discord.replace_mentions",
    "category": "function",
    "text": "replace_mentions(m::Message) -> String\n\nGet the Message contents with any User mentions replaced with their plaintext.\n\n\n\n\n\n"
},

{
    "location": "helpers.html#Discord.upload_file",
    "page": "Helpers",
    "title": "Discord.upload_file",
    "category": "function",
    "text": "upload_file(c::Client, ch::DiscordChanne, path::AbstractString; kwargs...) -> Message\n\nSend a Message with a file Attachment. Any keywords are passed on to create_message.\n\n\n\n\n\n"
},

{
    "location": "helpers.html#Discord.set_game",
    "page": "Helpers",
    "title": "Discord.set_game",
    "category": "function",
    "text": "set_game(\n    c::Client,\n    name::AbstractString,\n    type::Union{ActivityType, Int}=AT_GAME,\n    since::Union{Int, Nothing}=nothing,\n    status::Union{PresenceStatus, AbstractString}=PS_ONLINE,\n    afk::Bool=false,\n    kwargs...,\n) -> Bool\n\nShortcut for update_status to set the client\'s Activity.\n\n\n\n\n\n"
},

{
    "location": "helpers.html#Helpers-1",
    "page": "Helpers",
    "title": "Helpers",
    "category": "section",
    "text": "reply\nmention\nreplace_mentions\nupload_file\nset_game"
},

{
    "location": "types.html#",
    "page": "Types",
    "title": "Types",
    "category": "page",
    "text": "CurrentModule = Discord"
},

{
    "location": "types.html#Discord.Activity",
    "page": "Types",
    "title": "Discord.Activity",
    "category": "type",
    "text": "A User activity. More details here.\n\nFields\n\nname           :: String\ntype           :: ActivityType\nurl            :: Union{Missing, Nothing, String}\ntimestamps     :: Union{Missing, ActivityTimestamps}\napplication_id :: Union{Missing, UInt64}\ndetails        :: Union{Missing, Nothing, String}\nstate          :: Union{Missing, Nothing, String}\nparty          :: Union{Missing, ActivityParty}\nassets         :: Union{Missing, ActivityAssets}\nsecrets        :: Union{Missing, ActivitySecrets}\ninstance       :: Union{Missing, Bool}\nflags          :: Union{Missing, Int64}\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.ActivityTimestamps",
    "page": "Types",
    "title": "Discord.ActivityTimestamps",
    "category": "type",
    "text": "The start and stop times of an Activity. More details here.\n\nFields\n\nstart :: Union{Missing, DateTime}\nstop  :: Union{Missing, DateTime}\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.ActivityParty",
    "page": "Types",
    "title": "Discord.ActivityParty",
    "category": "type",
    "text": "The current party of an Activity\'s player. More details here.\n\nFields\n\nid   :: Union{Missing, String}\nsize :: Union{Missing, Array{Int64,1}}\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.ActivityAssets",
    "page": "Types",
    "title": "Discord.ActivityAssets",
    "category": "type",
    "text": "Images and hover text for an Activity. More details here.\n\nFields\n\nlarge_image :: Union{Missing, String}\nlarge_text  :: Union{Missing, String}\nsmall_image :: Union{Missing, String}\nsmall_text  :: Union{Missing, String}\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.ActivitySecrets",
    "page": "Types",
    "title": "Discord.ActivitySecrets",
    "category": "type",
    "text": "Secrets for Rich Presence joining and spectating of an Activity. More details here.\n\nFields\n\njoin     :: Union{Missing, String}\nspectate :: Union{Missing, String}\nmatch    :: Union{Missing, String}\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.ActivityType",
    "page": "Types",
    "title": "Discord.ActivityType",
    "category": "type",
    "text": "An Activity\'s type. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.ActivityFlags",
    "page": "Types",
    "title": "Discord.ActivityFlags",
    "category": "type",
    "text": "Flags which indicate what an Activity payload contains. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.Attachment",
    "page": "Types",
    "title": "Discord.Attachment",
    "category": "type",
    "text": "A Message attachment. More details here.\n\nFields\n\nid        :: UInt64\nfilename  :: String\nsize      :: Int64\nurl       :: String\nproxy_url :: String\nheight    :: Union{Missing, Int64}\nwidth     :: Union{Missing, Int64}\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.AuditLog",
    "page": "Types",
    "title": "Discord.AuditLog",
    "category": "type",
    "text": "An audit log. More details here.\n\nFields\n\nwebhooks          :: Array{Webhook,1}\nusers             :: Array{User,1}\naudit_log_entries :: Array{AuditLogEntry,1}\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.AuditLogEntry",
    "page": "Types",
    "title": "Discord.AuditLogEntry",
    "category": "type",
    "text": "An entry in an AuditLog. More details here.\n\nFields\n\ntarget_id   :: Union{Nothing, UInt64}\nchanges     :: Union{Missing, Array{AuditLogChange,1}}\nuser_id     :: UInt64\nid          :: UInt64\naction_type :: ActionType\noptions     :: Union{Missing, AuditLogOptions}\nreason      :: Union{Missing, String}\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.AuditLogChange",
    "page": "Types",
    "title": "Discord.AuditLogChange",
    "category": "type",
    "text": "A change item in an AuditLogEntry.\n\nThe first type parameter is the type of new_value and old_value. The second is the type of the entity that new_value and old_value belong(ed) to.\n\nMore details here.\n\nFields\n\nnew_value :: Union{Missing, T} where T\nold_value :: Union{Missing, T} where T\nkey       :: String\ntype      :: Type{U} where U\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.AuditLogOptions",
    "page": "Types",
    "title": "Discord.AuditLogOptions",
    "category": "type",
    "text": "Optional information in an AuditLogEntry. More details here.\n\nFields\n\ndelete_member_days :: Union{Missing, Int64}\nmembers_removed    :: Union{Missing, Int64}\nchannel_id         :: Union{Missing, UInt64}\ncount              :: Union{Missing, Int64}\nid                 :: Union{Missing, UInt64}\ntype               :: Union{Missing, OverwriteType}\nrole_name          :: Union{Missing, String}\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.ActionType",
    "page": "Types",
    "title": "Discord.ActionType",
    "category": "type",
    "text": "AuditLog action types. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.Ban",
    "page": "Types",
    "title": "Discord.Ban",
    "category": "type",
    "text": "A User ban. More details here.\n\nFields\n\nreason :: Union{Nothing, String}\nuser   :: User\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.DiscordChannel",
    "page": "Types",
    "title": "Discord.DiscordChannel",
    "category": "type",
    "text": "A Discord channel. More details here. Note: The name Channel is already used, hence the prefix.\n\nFields\n\nid                    :: UInt64\ntype                  :: ChannelType\nguild_id              :: Union{Missing, UInt64}\nposition              :: Union{Missing, Int64}\npermission_overwrites :: Union{Missing, Array{Overwrite,1}}\nname                  :: Union{Missing, String}\ntopic                 :: Union{Missing, Nothing, String}\nnsfw                  :: Union{Missing, Bool}\nlast_message_id       :: Union{Missing, Nothing, UInt64}\nbitrate               :: Union{Missing, Int64}\nuser_limit            :: Union{Missing, Int64}\nrate_limit_per_user   :: Union{Missing, Int64}\nrecipients            :: Union{Missing, Array{User,1}}\nicon                  :: Union{Missing, Nothing, String}\nowner_id              :: Union{Missing, UInt64}\napplication_id        :: Union{Missing, UInt64}\nparent_id             :: Union{Missing, Nothing, UInt64}\nlast_pin_timestamp    :: Union{Missing, Nothing, DateTime}\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.ChannelType",
    "page": "Types",
    "title": "Discord.ChannelType",
    "category": "type",
    "text": "A DiscordChannel\'s type.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.Connection",
    "page": "Types",
    "title": "Discord.Connection",
    "category": "type",
    "text": "A User connection to an external service (Twitch, YouTube, etc.). More details here.\n\nFields\n\nid           :: String\nname         :: String\ntype         :: String\nrevoked      :: Bool\nintegrations :: Array{Integration,1}\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.Embed",
    "page": "Types",
    "title": "Discord.Embed",
    "category": "type",
    "text": "A Message embed. More details here.\n\nFields\n\ntitle       :: Union{Missing, String}\ntype        :: Union{Missing, String}\ndescription :: Union{Missing, String}\nurl         :: Union{Missing, String}\ntimestamp   :: Union{Missing, DateTime}\ncolor       :: Union{Missing, Int64}\nfooter      :: Union{Missing, EmbedFooter}\nimage       :: Union{Missing, EmbedImage}\nthumbnail   :: Union{Missing, EmbedThumbnail}\nvideo       :: Union{Missing, EmbedVideo}\nprovider    :: Union{Missing, EmbedProvider}\nauthor      :: Union{Missing, EmbedAuthor}\nfields      :: Union{Missing, Array{EmbedField,1}}\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.EmbedThumbnail",
    "page": "Types",
    "title": "Discord.EmbedThumbnail",
    "category": "type",
    "text": "An Embed\'s thumbnail image information. More details here.\n\nFields\n\nurl       :: Union{Missing, String}\nproxy_url :: Union{Missing, String}\nheight    :: Union{Missing, Int64}\nwidth     :: Union{Missing, Int64}\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.EmbedVideo",
    "page": "Types",
    "title": "Discord.EmbedVideo",
    "category": "type",
    "text": "An Embed\'s video information. More details here.\n\nFields\n\nurl    :: Union{Missing, String}\nheight :: Union{Missing, Int64}\nwidth  :: Union{Missing, Int64}\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.EmbedImage",
    "page": "Types",
    "title": "Discord.EmbedImage",
    "category": "type",
    "text": "An Embed\'s image information. More details here.\n\nFields\n\nurl       :: Union{Missing, String}\nproxy_url :: Union{Missing, String}\nheight    :: Union{Missing, Int64}\nwidth     :: Union{Missing, Int64}\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.EmbedProvider",
    "page": "Types",
    "title": "Discord.EmbedProvider",
    "category": "type",
    "text": "An Embed\'s provider information. More details here.\n\nFields\n\nname :: Union{Missing, String}\nurl  :: Union{Missing, Nothing, String}\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.EmbedAuthor",
    "page": "Types",
    "title": "Discord.EmbedAuthor",
    "category": "type",
    "text": "An Embed\'s author information. More details here.\n\nFields\n\nname           :: Union{Missing, String}\nurl            :: Union{Missing, String}\nicon_url       :: Union{Missing, String}\nproxy_icon_url :: Union{Missing, String}\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.EmbedFooter",
    "page": "Types",
    "title": "Discord.EmbedFooter",
    "category": "type",
    "text": "An Embed\'s footer information. More details here.\n\nFields\n\ntext           :: String\nicon_url       :: Union{Missing, String}\nproxy_icon_url :: Union{Missing, String}\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.EmbedField",
    "page": "Types",
    "title": "Discord.EmbedField",
    "category": "type",
    "text": "An Embed field. More details here.\n\nFields\n\nname   :: String\nvalue  :: String\ninline :: Union{Missing, Bool}\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.Emoji",
    "page": "Types",
    "title": "Discord.Emoji",
    "category": "type",
    "text": "An emoji. More details here.\n\nFields\n\nid             :: Union{Nothing, UInt64}\nname           :: String\nroles          :: Union{Missing, Array{UInt64,1}}\nuser           :: Union{Missing, User}\nrequire_colons :: Union{Missing, Bool}\nmanaged        :: Union{Missing, Bool}\nanimated       :: Union{Missing, Bool}\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.AbstractGuild",
    "page": "Types",
    "title": "Discord.AbstractGuild",
    "category": "type",
    "text": "A guild (server). Can either be an UnavailableGuild or a Guild.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.Guild",
    "page": "Types",
    "title": "Discord.Guild",
    "category": "type",
    "text": "A guild (server). More details here.\n\nThe djl_* fields are internal fields used for cache performance.\n\nFields\n\nid                            :: UInt64\nname                          :: String\nicon                          :: Union{Nothing, String}\nsplash                        :: Union{Nothing, String}\nowner                         :: Union{Missing, Bool}\nowner_id                      :: Union{Missing, UInt64}\npermissions                   :: Union{Missing, Int64}\nregion                        :: Union{Missing, String}\nafk_channel_id                :: Union{Missing, Nothing, UInt64}\nafk_timeout                   :: Union{Missing, Int64}\nembed_enabled                 :: Union{Missing, Bool}\nembed_channel_id              :: Union{Missing, Nothing, UInt64}\nverification_level            :: VerificationLevel\ndefault_message_notifications :: Union{Missing, MessageNotificationLevel}\nexplicit_content_filter       :: Union{Missing, ExplicitContentFilterLevel}\nroles                         :: Union{Missing, Array{Role,1}}\nemojis                        :: Union{Missing, Array{Emoji,1}}\nfeatures                      :: Array{String,1}\nmfa_level                     :: Union{Missing, MFALevel}\napplication_id                :: Union{Missing, Nothing, UInt64}\nwidget_enabled                :: Union{Missing, Bool}\nwidget_channel_id             :: Union{Missing, Nothing, UInt64}\nsystem_channel_id             :: Union{Missing, Nothing, UInt64}\njoined_at                     :: Union{Missing, DateTime}\nlarge                         :: Union{Missing, Bool}\nunavailable                   :: Union{Missing, Bool}\nmember_count                  :: Union{Missing, Int64}\nvoice_states                  :: Union{Missing, Array{VoiceState,1}}\nmembers                       :: Union{Missing, Array{Member,1}}\nchannels                      :: Union{Missing, Array{DiscordChannel,1}}\npresences                     :: Union{Missing, Array{Presence,1}}\ndjl_users                     :: Union{Missing, Set{UInt64}}\ndjl_channels                  :: Union{Missing, Set{UInt64}}\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.UnavailableGuild",
    "page": "Types",
    "title": "Discord.UnavailableGuild",
    "category": "type",
    "text": "An unavailable guild (server). More details here.\n\nFields\n\nid          :: UInt64\nunavailable :: Union{Missing, Bool}\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.VerificationLevel",
    "page": "Types",
    "title": "Discord.VerificationLevel",
    "category": "type",
    "text": "A Guild\'s verification level. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.MessageNotificationLevel",
    "page": "Types",
    "title": "Discord.MessageNotificationLevel",
    "category": "type",
    "text": "A Guild\'s default message notification level. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.ExplicitContentFilterLevel",
    "page": "Types",
    "title": "Discord.ExplicitContentFilterLevel",
    "category": "type",
    "text": "A Guild\'s explicit content filter level. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.MFALevel",
    "page": "Types",
    "title": "Discord.MFALevel",
    "category": "type",
    "text": "A Guild\'s MFA level. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.GuildEmbed",
    "page": "Types",
    "title": "Discord.GuildEmbed",
    "category": "type",
    "text": "A Guild embed. More details here.\n\nFields\n\nenabled    :: Bool\nchannel_id :: Union{Nothing, UInt64}\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.Integration",
    "page": "Types",
    "title": "Discord.Integration",
    "category": "type",
    "text": "A Guild integration. More details here.\n\nFields\n\nid                  :: UInt64\nname                :: String\ntype                :: String\nenabled             :: Bool\nsyncing             :: Bool\nrole_id             :: UInt64\nexpire_behaviour    :: Int64\nexpire_grace_period :: Int64\nuser                :: User\naccount             :: IntegrationAccount\nsynced_at           :: Dates.DateTime\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.IntegrationAccount",
    "page": "Types",
    "title": "Discord.IntegrationAccount",
    "category": "type",
    "text": "An Integration account. More details here.\n\nFields\n\nid   :: String\nname :: String\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.Invite",
    "page": "Types",
    "title": "Discord.Invite",
    "category": "type",
    "text": "An invite to a Guild. More details here.\n\nFields\n\ncode                       :: String\nguild                      :: Union{Missing, Guild}\nchannel                    :: DiscordChannel\napproximate_presence_cound :: Union{Missing, Int64}\napproximate_member_count   :: Union{Missing, Int64}\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.InviteMetadata",
    "page": "Types",
    "title": "Discord.InviteMetadata",
    "category": "type",
    "text": "Metadata for an Invite. More details here.\n\nFields\n\ninviter    :: User\nuses       :: Int64\nmax_uses   :: Int64\nmax_age    :: Int64\ntemporary  :: Bool\ncreated_at :: Dates.DateTime\nrevoked    :: Bool\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.Member",
    "page": "Types",
    "title": "Discord.Member",
    "category": "type",
    "text": "A Guild member. More details here.\n\nFields\n\nuser      :: Union{Missing, User}\nnick      :: Union{Missing, Nothing, String}\nroles     :: Array{UInt64,1}\njoined_at :: Dates.DateTime\ndeaf      :: Bool\nmute      :: Bool\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.Message",
    "page": "Types",
    "title": "Discord.Message",
    "category": "type",
    "text": "A message. More details here.\n\nFields\n\nid               :: UInt64\nchannel_id       :: UInt64\nguild_id         :: Union{Missing, UInt64}\nauthor           :: Union{Missing, User}\nmember           :: Union{Missing, Member}\ncontent          :: Union{Missing, String}\ntimestamp        :: Union{Missing, DateTime}\nedited_timestamp :: Union{Missing, Nothing, DateTime}\ntts              :: Union{Missing, Bool}\nmention_everyone :: Union{Missing, Bool}\nmentions         :: Union{Missing, Array{User,1}}\nmention_roles    :: Union{Missing, Array{UInt64,1}}\nattachments      :: Union{Missing, Array{Attachment,1}}\nembeds           :: Union{Missing, Array{Embed,1}}\nreactions        :: Union{Missing, Array{Reaction,1}}\nnonce            :: Union{Missing, Nothing, UInt64}\npinned           :: Union{Missing, Bool}\nwebhook_id       :: Union{Missing, UInt64}\ntype             :: Union{Missing, MessageType}\nactivity         :: Union{Missing, MessageActivity}\napplication      :: Union{Missing, MessageApplication}\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.MessageActivity",
    "page": "Types",
    "title": "Discord.MessageActivity",
    "category": "type",
    "text": "A Message activity. More details here.\n\nFields\n\ntype     :: MessageActivityType\nparty_id :: Union{Missing, String}\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.MessageApplication",
    "page": "Types",
    "title": "Discord.MessageApplication",
    "category": "type",
    "text": "A Rich Presence Message\'s application information. More details here.\n\nFields\n\nid          :: UInt64\ncover_image :: String\ndescription :: String\nicon        :: String\nname        :: String\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.MessageType",
    "page": "Types",
    "title": "Discord.MessageType",
    "category": "type",
    "text": "A Message\'s type. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.MessageActivityType",
    "page": "Types",
    "title": "Discord.MessageActivityType",
    "category": "type",
    "text": "A Message\'s activity type. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.Overwrite",
    "page": "Types",
    "title": "Discord.Overwrite",
    "category": "type",
    "text": "A permission overwrite. More details here.\n\nFields\n\nid    :: UInt64\ntype  :: OverwriteType\nallow :: Int64\ndeny  :: Int64\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.OverwriteType",
    "page": "Types",
    "title": "Discord.OverwriteType",
    "category": "type",
    "text": "An Overwrite\'s type. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.Presence",
    "page": "Types",
    "title": "Discord.Presence",
    "category": "type",
    "text": "A User\'s presence. More details here.\n\nFields\n\nuser       :: User\nroles      :: Union{Missing, Array{UInt64,1}}\ngame       :: Union{Nothing, Activity}\nguild_id   :: Union{Missing, UInt64}\nstatus     :: PresenceStatus\nactivities :: Array{Activity,1}\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.PresenceStatus",
    "page": "Types",
    "title": "Discord.PresenceStatus",
    "category": "type",
    "text": "A User\'s status sent in a Presence. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.Reaction",
    "page": "Types",
    "title": "Discord.Reaction",
    "category": "type",
    "text": "A Message reaction. More details here.\n\nFields\n\ncount :: Int64\nme    :: Bool\nemoji :: Emoji\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.Role",
    "page": "Types",
    "title": "Discord.Role",
    "category": "type",
    "text": "A User role. More details here.\n\nFields\n\nid          :: UInt64\nname        :: String\ncolor       :: Int64\nhoist       :: Bool\nposition    :: Int64\npermissions :: Int64\nmanaged     :: Bool\nmentionable :: Bool\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.User",
    "page": "Types",
    "title": "Discord.User",
    "category": "type",
    "text": "A Discord user. More details here.\n\nFields\n\nid            :: UInt64\nusername      :: Union{Missing, String}\ndiscriminator :: Union{Missing, String}\navatar        :: Union{Missing, Nothing, String}\nbot           :: Union{Missing, Bool}\nmfa_enabled   :: Union{Missing, Bool}\nlocale        :: Union{Missing, String}\nverified      :: Union{Missing, Bool}\nemail         :: Union{Missing, Nothing, String}\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.VoiceRegion",
    "page": "Types",
    "title": "Discord.VoiceRegion",
    "category": "type",
    "text": "A region for a Guild\'s voice server. More details here.\n\nFields\n\nid         :: String\nname       :: String\nvip        :: Bool\noptimal    :: Bool\ndeprecated :: Bool\ncustom     :: Bool\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.VoiceState",
    "page": "Types",
    "title": "Discord.VoiceState",
    "category": "type",
    "text": "A User\'s voice connection status. More details here.\n\nFields\n\nguild_id   :: Union{Missing, UInt64}\nchannel_id :: Union{Nothing, UInt64}\nuser_id    :: UInt64\nmember     :: Union{Missing, Member}\nsession_id :: String\ndeaf       :: Bool\nmute       :: Bool\nself_deaf  :: Bool\nself_mute  :: Bool\nsuppress   :: Bool\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.Webhook",
    "page": "Types",
    "title": "Discord.Webhook",
    "category": "type",
    "text": "A Webhook. More details here.\n\nFields\n\nid         :: UInt64\nguild_id   :: Union{Missing, UInt64}\nchannel_id :: UInt64\nuser       :: Union{Missing, User}\nname       :: Union{Nothing, String}\navatar     :: Union{Nothing, String}\ntoken      :: String\n\n\n\n\n\n"
},

{
    "location": "types.html#Types-1",
    "page": "Types",
    "title": "Types",
    "category": "section",
    "text": "This page is organized in mostly-alphabetical order. Note that Snowflake ===  UInt64. Unions with Nothing indicate that a field is nullable, whereas Unions with Missing indicate that a field is optional. More details here.Activity\nActivityTimestamps\nActivityParty\nActivityAssets\nActivitySecrets\nActivityType\nActivityFlags\nAttachment\nAuditLog\nAuditLogEntry\nAuditLogChange\nAuditLogOptions\nActionType\nBan\nDiscordChannel\nChannelType\nConnection\nEmbed\nEmbedThumbnail\nEmbedVideo\nEmbedImage\nEmbedProvider\nEmbedAuthor\nEmbedFooter\nEmbedField\nEmoji\nAbstractGuild\nGuild\nUnavailableGuild\nVerificationLevel\nMessageNotificationLevel\nExplicitContentFilterLevel\nMFALevel\nGuildEmbed\nIntegration\nIntegrationAccount\nInvite\nInviteMetadata\nMember\nMessage\nMessageActivity\nMessageApplication\nMessageType\nMessageActivityType\nOverwrite\nOverwriteType\nPresence\nPresenceStatus\nReaction\nRole\nUser\nVoiceRegion\nVoiceState\nWebhook"
},

{
    "location": "tutorial.html#",
    "page": "Tutorial",
    "title": "Tutorial",
    "category": "page",
    "text": "CurrentModule = Discord"
},

{
    "location": "tutorial.html#Tutorial-1",
    "page": "Tutorial",
    "title": "Tutorial",
    "category": "section",
    "text": "The completed and cleaned-up code can be found in wager.jl.In this tutorial, we\'re going to build a very basic currency/wager bot with Discord.jl. The bot will give users the following capabilities:Receive tokens from the bot on a regular interval\nSee their current token count\nSee a leaderboard of the top earners in the guild\nGive tokens to other users by username\nWager tokens on a coin flipA couple of rules apply:Users cannot wager or give more tokens than they currently have (this means that users cannot go into debt)\nUsers cannot give tokens to users in a different guildLet\'s get started! First of all, we need to import Discord.jl, and we\'ll also start a main function which we\'ll add to as we go along.using Discord\n\nfunction main()\n    c = Client(ENV[\"DISCORD_TOKEN\"])\n    # To be continued...\nendNext, let\'s think about how we want to maintain the state of our application. According to the requirements and rules outlined above, we need to track users by username and their token count, which is nonnegative, by guild. Therefore, our internal state representation is going to be a mapping from guild IDs to mappings from usernames to token counts via a Dict{Discord.Snowflake, Dict{String, UInt}}. In this example, we aren\'t particularly concerned with persistent storage so we\'ll just keep everything in memory.const TOKENS = Dict{Discord.Snowflake, Dict{String, UInt}}()Now, since this Dict starts off empty, how are we going to populate it with users? We can do this by defining a handler on GuildCreate, whose guild field contains its own ID, as well as a list of Members, each of which contains a User, and therefore a username.const TOKEN_START = 100\n\nfunction add_users(c::Client, e::GuildCreate)\n    if !haskey(TOKENS, e.guild.id)\n        TOKENS[e.guild.id] = Dict()\n    end\n\n    guild = TOKENS[e.guild.id]\n\n    for m in e.guild.members\n        if !haskey(guild, m.user.username)\n            guild[m.user.username] = TOKEN_START\n        end\n    end\nendLet\'s add that handler to our Client, and connect to the gateway with open:function main()\n    # ...\n    add_handler!(c, GuildCreate, add_users)\n    open(c)\nendWith that taken care of, we can start distributing tokens. First, we need to decide how often to distribute tokens, and how many should be given.using Dates\n\nconst TOKEN_INTERVAL = Minute(30)\nconst TOKEN_INCREMENT = 100Now, we can write a function to give out tokens on this interval, and get it running in the background.function distribute_tokens(c::Client)\n    while isopen(c)\n        for g in keys(TOKENS)\n            for u in keys(g)\n                g[u] += TOKEN_INCREMENT\n            end\n        end\n        sleep(TOKEN_INTERVAL)\n    end\nend\n\nfunction main()\n    # ...\n    @async distribute_tokens()\nendNext, we need to let users see their token count. We can do this by adding a few helpers, and a command via add_command!.# Insert a guild and/or user from a message into the token cache if they don\'t exist.\nfunction ensure_updated(m::Discord.Message)\n    if !haskey(TOKENS, m.guild_id)\n        TOKENS[m.guild_id] = Dict()\n    end\n    if !haskey(TOKENS[m.guild_id], m.author.username)\n        TOKENS[m.guild_id][m.author.username] = TOKEN_START\n    end\nend\n\n# Get the token count for the user who sent a message.\ntoken_count(m::Discord.Message) = get(get(TOKENS, m.guild_id, Dict()), m.author.username, 0)\n\nfunction reply_token_count(c::Client, m::Discord.Message)\n    ensure_updated(m)\n    reply(c, m, \"You have $(token_count(m)) tokens.\")\nend\n\nfunction main()\n    # ...\n    add_command!(c, \"!count\", reply_token_count)\nendWhen a user types \"!count\", the bot will reply with their token count. Next, we can easily implement the guild leaderboard for the \"!leaderboard\" command.function reply_token_leaderboard(c::Client, m::Discord.Message)\n    ensure_updated(m)\n\n    # Get user => token count pairs by token count in descending order.\n    sorted = sort(collect(TOKENS[m.guild_id]); by=p -> p.second, rev=true)\n\n    entries = String[]\n    for i in 1:min(10, length(sorted))  # Display at most 10.\n        user, tokens = sorted[i]\n        push!(entries, \"$user: $tokens\")\n    end\n\n    reply(c, m, join(entries, \"\\n\"))\nend\n\nfunction main()\n    # ...\n    add_command!(c, \"!leaderboard\", reply_token_leaderboard)\nendNext, we can implement the sending of tokens between users. We need to do a few new things:Parse the number of tokens and the recipient from the command\nCheck that the user sending the tokens has enough to send\nCheck that both users are in the same guildfunction send_tokens(c::Client, m::Discord.Message)\n    ensure_updated(m)\n\n    words = split(m.content)\n    if length(words) < 3\n        return reply(c, m, \"Invalid !send command.\")\n    end\n\n    tokens = try\n        parse(UInt, words[2])\n    catch\n        return reply(c, m, \"\'$(words[2])\' is not a valid number of tokens.\")\n    end\n    recipient = words[3]\n    if !haskey(TOKENS[m.guild_id], recipient)\n        return reply(c, m, \"Couldn\'t find user \'$recipient\' in this guild.\")\n    end\n    if token_count(m) < tokens\n        return reply(c, m, \"You don\'t have enough tokens to give.\")\n    end\n\n    TOKENS[m.guild_id][m.author.username] -= tokens\n    TOKENS[m.guild_id][recipient] += tokens\n    reply(c, m, \"You sent $tokens tokens to $recipient.\")\nend\n\nfunction main()\n    # ...\n    add_command!(c, \"!send\", send_tokens)\nendEasy! And last but not least, we\'ll add the wagering command.function wager_tokens(c::Client, m::Discord.Message)\n    ensure_updated(m)\n\n    words = split(m.content)\n    if length(words) < 2\n        return reply(c, m, \"Invalid !wager command.\")\n    end\n\n    tokens = try\n        parse(UInt, words[2])\n    catch\n        return reply(c, m, \"\'$(words[2])\' is not a valid number of tokens.\")\n    end\n    if token_count(m) < tokens\n        return reply(c, m, \"You don\'t have enough tokens to wager.\")\n    end\n\n    if rand() > 0.5\n        TOKENS[m.guild_id][m.author.username] += tokens\n        reply(c, m, \"You win!\")\n    else\n        TOKENS[m.guild_id][m.author.username] -= tokens\n        reply(c, m, \"You lose.\")\n    end\nend\n\nfunction main()\n    # ...\n    add_command!(c, \"!wager\", wager_tokens)\n    wait(c)\nendThe wait command at the end of main blocks until the client disconnects.And that\'s it! Run this main function with the $DISCORD_TOKEN environment variable set and see your bot in action.note: Note\nPlenty of corners were cut here, so please don\'t see this as best practices for bot creation! It\'s just meant to demonstrate some features and help you get your feet wet."
},

]}
