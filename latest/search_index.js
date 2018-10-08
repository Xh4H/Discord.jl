var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#Julicord.Client",
    "page": "Home",
    "title": "Julicord.Client",
    "category": "type",
    "text": "Client(token::String) -> Client\n\nA Discord bot.\n\nArguments\n\ntoken::String: The bot\'s token.\n\n\n\n\n\n"
},

{
    "location": "index.html#Julicord.MessageDelete-Tuple{Dict}",
    "page": "Home",
    "title": "Julicord.MessageDelete",
    "category": "method",
    "text": "A message delete event. More details here.\n\n\n\n\n\n"
},

{
    "location": "index.html#Julicord.UnknownEvent",
    "page": "Home",
    "title": "Julicord.UnknownEvent",
    "category": "type",
    "text": "An unknown event.\n\n\n\n\n\n"
},

{
    "location": "index.html#Julicord.User-Tuple{Dict}",
    "page": "Home",
    "title": "Julicord.User",
    "category": "method",
    "text": "A Discord user.  More details here.\n\n\n\n\n\n"
},

{
    "location": "index.html#Julicord.add_handler!-Tuple{Client,Type{#s244} where #s244<:AbstractEvent,Function}",
    "page": "Home",
    "title": "Julicord.add_handler!",
    "category": "method",
    "text": "add_handler!(c::Client, evt::Type{<:AbstractEvent}, func::Function)\n\nAdd a handler for the given event type. The handler is appended the event\'s current handlers.\n\n\n\n\n\n"
},

{
    "location": "index.html#Julicord.clear_handlers!-Tuple{Client,Type{#s244} where #s244<:AbstractEvent}",
    "page": "Home",
    "title": "Julicord.clear_handlers!",
    "category": "method",
    "text": "clear_handlers!(c::Client, evt::Type{<:AbstractEvent})\n\nRemoves all handlers for the given event type.\n\n\n\n\n\n"
},

{
    "location": "index.html#Julicord.me-Tuple{Client}",
    "page": "Home",
    "title": "Julicord.me",
    "category": "method",
    "text": "me(c::Client) -> Dict{String, Any}\n\nGet the client\'s bot user.\n\n\n\n\n\n"
},

{
    "location": "index.html#Julicord.state-Tuple{Client}",
    "page": "Home",
    "title": "Julicord.state",
    "category": "method",
    "text": "state(c::Client) -> Dict{String, Any}\n\nGet the client state.\n\n\n\n\n\n"
},

{
    "location": "index.html#Julicord.Activity-Tuple{Dict}",
    "page": "Home",
    "title": "Julicord.Activity",
    "category": "method",
    "text": "A user activity. More details here.\n\n\n\n\n\n"
},

{
    "location": "index.html#Julicord.Attachment-Tuple{Dict}",
    "page": "Home",
    "title": "Julicord.Attachment",
    "category": "method",
    "text": "A message attachment. More details here.\n\n\n\n\n\n"
},

{
    "location": "index.html#Julicord.DiscordChannel-Tuple{Dict}",
    "page": "Home",
    "title": "Julicord.DiscordChannel",
    "category": "method",
    "text": "A Discord channel. More details here. Note: The name Channel is already used, hence the prefix.\n\n\n\n\n\n"
},

{
    "location": "index.html#Julicord.Embed-Tuple{Dict}",
    "page": "Home",
    "title": "Julicord.Embed",
    "category": "method",
    "text": "A message embed. More details here.\n\n\n\n\n\n"
},

{
    "location": "index.html#Julicord.Emoji-Tuple{Dict}",
    "page": "Home",
    "title": "Julicord.Emoji",
    "category": "method",
    "text": "An emoji. More details here.\n\n\n\n\n\n"
},

{
    "location": "index.html#Julicord.Guild-Tuple{Dict}",
    "page": "Home",
    "title": "Julicord.Guild",
    "category": "method",
    "text": "A guild (server). More details here.\n\n\n\n\n\n"
},

{
    "location": "index.html#Julicord.GuildMember-Tuple{Dict}",
    "page": "Home",
    "title": "Julicord.GuildMember",
    "category": "method",
    "text": "A guild member. More details here.\n\n\n\n\n\n"
},

{
    "location": "index.html#Julicord.Message-Tuple{Dict}",
    "page": "Home",
    "title": "Julicord.Message",
    "category": "method",
    "text": "A message. More details here.\n\n\n\n\n\n"
},

{
    "location": "index.html#Julicord.Presence-Tuple{Dict}",
    "page": "Home",
    "title": "Julicord.Presence",
    "category": "method",
    "text": "A user presence. More details here.\n\n\n\n\n\n"
},

{
    "location": "index.html#Julicord.Reaction-Tuple{Dict}",
    "page": "Home",
    "title": "Julicord.Reaction",
    "category": "method",
    "text": "A reaction. More details here.\n\n\n\n\n\n"
},

{
    "location": "index.html#Julicord.Role-Tuple{Dict}",
    "page": "Home",
    "title": "Julicord.Role",
    "category": "method",
    "text": "A role. More details here.\n\n\n\n\n\n"
},

{
    "location": "index.html#Julicord.UnavailableGuild-Tuple{Dict}",
    "page": "Home",
    "title": "Julicord.UnavailableGuild",
    "category": "method",
    "text": "An unavailable guild (server). More details here.\n\n\n\n\n\n"
},

{
    "location": "index.html#Julicord.VoiceState-Tuple{Dict}",
    "page": "Home",
    "title": "Julicord.VoiceState",
    "category": "method",
    "text": "A voice state. More details here.\n\n\n\n\n\n"
},

{
    "location": "index.html#Julicord.Webhook-Tuple{Dict}",
    "page": "Home",
    "title": "Julicord.Webhook",
    "category": "method",
    "text": "A Webhook. More details heret.\n\n\n\n\n\n"
},

{
    "location": "index.html#Base.open-Tuple{Client}",
    "page": "Home",
    "title": "Base.open",
    "category": "method",
    "text": "open(c::Client)\n\nLog in to the Discord gateway and begin reading events.\n\n\n\n\n\n"
},

{
    "location": "index.html#Base.wait-Tuple{Client}",
    "page": "Home",
    "title": "Base.wait",
    "category": "method",
    "text": "wait(c::Client)\n\nWait for an open client to close.\n\n\n\n\n\n"
},

{
    "location": "index.html#Julicord-1",
    "page": "Home",
    "title": "Julicord",
    "category": "section",
    "text": "Modules = [Julicord]"
},

]}
