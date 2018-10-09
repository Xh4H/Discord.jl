var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#Julicord-1",
    "page": "Home",
    "title": "Julicord",
    "category": "section",
    "text": "TODO: user-friendly documentation."
},

{
    "location": "reference.html#Julicord.AbstractEvent",
    "page": "Reference",
    "title": "Julicord.AbstractEvent",
    "category": "type",
    "text": "An incoming event sent over the gateway. Also a catch-all event: Handlers defined on this type will execute on all events.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.Activity-Tuple{Dict{String,Any}}",
    "page": "Reference",
    "title": "Julicord.Activity",
    "category": "method",
    "text": "A user activity. More details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.Client",
    "page": "Reference",
    "title": "Julicord.Client",
    "category": "type",
    "text": "Client(token::String) -> Client\n\nA Discord bot.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.UnknownEvent",
    "page": "Reference",
    "title": "Julicord.UnknownEvent",
    "category": "type",
    "text": "An unknown event.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.add_handler!-Tuple{Client,Type{#s358} where #s358<:AbstractEvent,Function}",
    "page": "Reference",
    "title": "Julicord.add_handler!",
    "category": "method",
    "text": "add_handler!(c::Client, evt::Type{<:AbstractEvent}, func::Function)\n\nAdd a handler for the given event type. The handler should be a function which takes two arguments: A Client and an AbstractEvent (or a subtype). The handler is appended the event\'s current handlers.\n\nnote: Note\nThe set of handlers for a given event is stored as a Set{Function}. This protects against adding duplicate handlers, except when you pass an anonymous function. Therefore, it\'s recommended to define your handler functions beforehand.Also note that there is no guarantee on the order in which handlers run.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.clear_handlers!-Tuple{Client,Type{#s358} where #s358<:AbstractEvent}",
    "page": "Reference",
    "title": "Julicord.clear_handlers!",
    "category": "method",
    "text": "clear_handlers!(c::Client, evt::Type{<:AbstractEvent})\n\nRemoves all handlers for the given event type.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.me-Tuple{Client}",
    "page": "Reference",
    "title": "Julicord.me",
    "category": "method",
    "text": "me(c::Client) -> Union{User, Nothing}\n\nGet the client\'s bot user.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.request_guild_members-Tuple{Client,UInt64}",
    "page": "Reference",
    "title": "Julicord.request_guild_members",
    "category": "method",
    "text": "request_guild_members(\n    c::Client,\n    guild_id::Union{Snowflake, Vector{Snowflake};\n    query::AbstractString=\"\",\n    limit::Int=0,\n) -> Bool\n\nRequest offline guild members of one or more guilds. More details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.state-Tuple{Client}",
    "page": "Reference",
    "title": "Julicord.state",
    "category": "method",
    "text": "state(c::Client) -> State\n\nGet the client state.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.update_status-Tuple{Client,Union{Nothing, Int64},Union{Nothing, Activity},Julicord.PresenceStatus,Bool}",
    "page": "Reference",
    "title": "Julicord.update_status",
    "category": "method",
    "text": "update_status(\n    c::Client,\n    since::Union{Int, Nothing},\n    activity::Union{Activity, Nothing},\n    status::PresenceStatus,\n    afk::Bool,\n) -> Bool\n\nIndicate a presence or status update. More details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.Attachment-Tuple{Dict{String,Any}}",
    "page": "Reference",
    "title": "Julicord.Attachment",
    "category": "method",
    "text": "A message attachment. More details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.Ban-Tuple{Dict{String,Any}}",
    "page": "Reference",
    "title": "Julicord.Ban",
    "category": "method",
    "text": "A user ban. More details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.DiscordChannel-Tuple{Dict{String,Any}}",
    "page": "Reference",
    "title": "Julicord.DiscordChannel",
    "category": "method",
    "text": "A Discord channel. More details here. Note: The name Channel is already used, hence the prefix.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.Embed-Tuple{Dict{String,Any}}",
    "page": "Reference",
    "title": "Julicord.Embed",
    "category": "method",
    "text": "A message embed. More details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.Emoji-Tuple{Dict{String,Any}}",
    "page": "Reference",
    "title": "Julicord.Emoji",
    "category": "method",
    "text": "An emoji. More details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.Guild-Tuple{Dict{String,Any}}",
    "page": "Reference",
    "title": "Julicord.Guild",
    "category": "method",
    "text": "A guild (server). More details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.Integration-Tuple{Dict{String,Any}}",
    "page": "Reference",
    "title": "Julicord.Integration",
    "category": "method",
    "text": "A server integration. More details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.Invite-Tuple{Dict{String,Any}}",
    "page": "Reference",
    "title": "Julicord.Invite",
    "category": "method",
    "text": "An invite to a guild. More details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.InviteMetadata-Tuple{Dict{String,Any}}",
    "page": "Reference",
    "title": "Julicord.InviteMetadata",
    "category": "method",
    "text": "Metadata for an Invite. More details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.Member-Tuple{Dict{String,Any}}",
    "page": "Reference",
    "title": "Julicord.Member",
    "category": "method",
    "text": "A guild member. More details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.Message-Tuple{Dict{String,Any}}",
    "page": "Reference",
    "title": "Julicord.Message",
    "category": "method",
    "text": "A message. More details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.Presence-Tuple{Dict{String,Any}}",
    "page": "Reference",
    "title": "Julicord.Presence",
    "category": "method",
    "text": "A user presence. More details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.Reaction-Tuple{Dict{String,Any}}",
    "page": "Reference",
    "title": "Julicord.Reaction",
    "category": "method",
    "text": "A reaction. More details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.Role-Tuple{Dict{String,Any}}",
    "page": "Reference",
    "title": "Julicord.Role",
    "category": "method",
    "text": "A user role. More details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.UnavailableGuild-Tuple{Dict{String,Any}}",
    "page": "Reference",
    "title": "Julicord.UnavailableGuild",
    "category": "method",
    "text": "An unavailable guild (server). More details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.User-Tuple{Dict{String,Any}}",
    "page": "Reference",
    "title": "Julicord.User",
    "category": "method",
    "text": "A Discord user. More details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.VoiceState-Tuple{Dict{String,Any}}",
    "page": "Reference",
    "title": "Julicord.VoiceState",
    "category": "method",
    "text": "A users\'s voice connection status. More details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.Webhook-Tuple{Dict{String,Any}}",
    "page": "Reference",
    "title": "Julicord.Webhook",
    "category": "method",
    "text": "A Webhook. More details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Base.open-Tuple{Client}",
    "page": "Reference",
    "title": "Base.open",
    "category": "method",
    "text": "open(c::Client)\n\nLog in to the Discord gateway and begin responding to events.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Base.wait-Tuple{Client}",
    "page": "Reference",
    "title": "Base.wait",
    "category": "method",
    "text": "wait(c::Client)\n\nWait for an open client to close.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.update_voice_state-Tuple{Client,UInt64,Union{Nothing, UInt64},Bool,Bool}",
    "page": "Reference",
    "title": "Julicord.update_voice_state",
    "category": "method",
    "text": "update_voice_state(\n    c::Client,\n    guild_id::Snowflake,\n    channel_id::Union{Snowflake, Nothing},\n    self_mute::Bool,\n    self_deaf::Bool,\n) -> Bool\n\nJoin, move, or disconnect from a voice channel. More details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#",
    "page": "Reference",
    "title": "Reference",
    "category": "page",
    "text": "Modules = [Julicord]"
},

]}
