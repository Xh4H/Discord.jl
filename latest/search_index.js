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
    "location": "index.html#Why-Julia?-1",
    "page": "Home",
    "title": "Why Julia?",
    "category": "section",
    "text": "TODO"
},

{
    "location": "index.html#Example-1",
    "page": "Home",
    "title": "Example",
    "category": "section",
    "text": "For usage examples, see the examples/ directory."
},

{
    "location": "index.html#Index-1",
    "page": "Home",
    "title": "Index",
    "category": "section",
    "text": ""
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
    "text": "Client(\n    token::String;\n    on_limit::OnLimit=LIMIT_IGNORE,\n    ttl::Period=Hour(1),\n    version::Int=6,\n ) -> Client\n\nA Discord bot. Clients can connect to the gateway, respond to events, and make REST API calls to perform actions such as sending/deleting messages, kicking/banning users, etc.\n\nTo get a bot token, head here to create a new application. Once you\'ve created a bot user, you will have access to its token.\n\nKeywords\n\non_limit::OnLimit=LIMIT_IGNORE: Client\'s behaviour when it hits a rate limit (see \"Rate Limiting\" below for more details).\nttl::Period=Hour(1) Amount of time that cache entries are kept (see \"Caching\" below for more details).\nversion::Int=6: Version of the Discord API to use. Using anything but 6 is not officially supported by the Discord.jl developers.\n\nCaching\n\nBy default, most data that comes from Discord is cached for later use. However, to avoid memory leakage, it\'s deleted after some time (determined by the ttl keyword). Although it\'s not recommended, you can also disable caching of certain data by clearing default handlers for relevant event types with clear_handlers!. For example, if you wanted to avoid caching any messages, you would clear handlers for MessageCreate and MessageUpdate events.\n\nRate Limiting\n\nDiscord enforces rate limits on usage of its REST API. This  means you can  only send so many messages in a given period, and so on. To customize the client\'s behaviour when encountering rate limits, use the on_limit keyword and see OnLimit.\n\nSharding\n\nSharding is handled automatically: The number of available processes is the number of shards that are created. See the sharding example for more details.\n\n\n\n\n\n"
},

{
    "location": "client.html#Base.open",
    "page": "Client",
    "title": "Base.open",
    "category": "function",
    "text": "open(c::Client)\n\nConnect to the Discord gateway and begin responding to events.\n\n\n\n\n\n"
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
    "text": "Base.close(c::Client)\n\nDisconnect from the Discord gateway.\n\n\n\n\n\n"
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
    "text": "me(c::Client) -> Union{User, Nothing}\n\nGet the client\'s bot user.\n\n\n\n\n\n"
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
    "text": "add_handler!(\n    c::Client,\n    evt::Type{<:AbstractEvent},\n    func::Function;\n    tag::Symbol=gensym(),\n    expiry::Union{Int, Period}=-1,\n)\n\nAdd a handler for an event type. The handler should be a function which takes two arguments: A Client and an AbstractEvent (or a subtype). The handler is appended the event\'s current handlers.\n\nKeywords\n\ntag::Symbol=gensym(): A label for the handler, which can be used to remove it with delete_handler!.\nexpiry::Union{Int, Period}=-1: The handler\'s expiry. If an Int is given, the handler will run a set number of times before expiring. If a Period is given, the handler will expire after that amount of time has elapsed. The default of -1 indicates no expiry.\n\nnote: Note\nThere is no guarantee on the order in which handlers run, except that catch-all (AbstractEvent) handlers run before specific ones.\n\n\n\n\n\n"
},

{
    "location": "client.html#Discord.add_command!",
    "page": "Client",
    "title": "Discord.add_command!",
    "category": "function",
    "text": "add_command!(\n    c::Client,\n    prefix::AbstractString,\n    func::Function;\n    tag::Symbol=gensym(),\n    expiry::Union{Int, Period}=-1,\n)\n\nAdd a text command handler. The handler function should take two arguments: A Client and a Message. The keyword arguments are identical to add_handler!.\n\n\n\n\n\n"
},

{
    "location": "client.html#Discord.delete_handler!",
    "page": "Client",
    "title": "Discord.delete_handler!",
    "category": "function",
    "text": "delete_handler!(c::Client, evt::Type{<:AbstractEvent}, tag::Symbol)\n\nDelete a single handler by event type and tag.\n\n\n\n\n\n"
},

{
    "location": "client.html#Discord.clear_handlers!",
    "page": "Client",
    "title": "Discord.clear_handlers!",
    "category": "function",
    "text": "clear_handlers!(c::Client, evt::Type{<:AbstractEvent})\n\nRemove all handlers for an event type. Using this is generally not recommended because it also clears default handlers which maintain the client state. Instead, it\'s preferred add handlers with specific tags and delete them with delete_handler!.\n\n\n\n\n\n"
},

{
    "location": "client.html#Event-Handlers-1",
    "page": "Client",
    "title": "Event Handlers",
    "category": "section",
    "text": "add_handler!\nadd_command!\ndelete_handler!\nclear_handlers!"
},

{
    "location": "client.html#Discord.request_guild_members",
    "page": "Client",
    "title": "Discord.request_guild_members",
    "category": "function",
    "text": "request_guild_members(\n    c::Client,\n    guild_id::Union{Snowflake, Vector{Snowflake};\n    query::AbstractString=\"\",\n    limit::Int=0,\n) -> Bool\n\nRequest offline guild members of one or more guilds. GuildMemberChunk events are sent by the gateway in response.\n\nMore details here.\n\n\n\n\n\n"
},

{
    "location": "client.html#Discord.update_voice_state",
    "page": "Client",
    "title": "Discord.update_voice_state",
    "category": "function",
    "text": "update_voice_state(\n    c::Client,\n    guild_id::Snowflake,\n    channel_id::Union{Snowflake, Nothing},\n    self_mute::Bool,\n    self_deaf::Bool,\n) -> Bool\n\nJoin, move, or disconnect from a voice channel. A VoiceStateUpdate event is sent by the gateway in response.\n\nMore details here.\n\n\n\n\n\n"
},

{
    "location": "client.html#Discord.update_status",
    "page": "Client",
    "title": "Discord.update_status",
    "category": "function",
    "text": "update_status(\n    c::Client,\n    since::Union{Int, Nothing},\n    activity::Union{Activity, Nothing},\n    status::PresenceStatus,\n    afk::Bool,\n) -> Bool\n\nIndicate a presence or status update. A PresenceUpdate event is sent by the gateway in response.\n\nMore details here.\n\n\n\n\n\n"
},

{
    "location": "client.html#Gateway-Commands-1",
    "page": "Client",
    "title": "Gateway Commands",
    "category": "section",
    "text": "request_guild_members\nupdate_voice_state\nupdate_status"
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
    "text": "AbstractEvent\nUnknownEvent"
},

{
    "location": "events.html#Discord.ChannelCreate",
    "page": "Events",
    "title": "Discord.ChannelCreate",
    "category": "type",
    "text": "Sent when a new DiscordChannel is created.\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.ChannelUpdate",
    "page": "Events",
    "title": "Discord.ChannelUpdate",
    "category": "type",
    "text": "Sent when a DiscordChannel is updated.\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.ChannelDelete",
    "page": "Events",
    "title": "Discord.ChannelDelete",
    "category": "type",
    "text": "Sent when a DiscordChannel is deleted.\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.ChannelPinsUpdate",
    "page": "Events",
    "title": "Discord.ChannelPinsUpdate",
    "category": "type",
    "text": "Sent when a DiscordChannel\'s pins are updated.\n\n\n\n\n\n"
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
    "text": "Sent when a new Guild is created.\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.GuildUpdate",
    "page": "Events",
    "title": "Discord.GuildUpdate",
    "category": "type",
    "text": "Sent when a Guild is updated.\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.GuildDelete",
    "page": "Events",
    "title": "Discord.GuildDelete",
    "category": "type",
    "text": "Sent when a guild is deleted, and contains an UnavailableGuild.\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.GuildBanAdd",
    "page": "Events",
    "title": "Discord.GuildBanAdd",
    "category": "type",
    "text": "Sent when a User is banned from a Guild.\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.GuildBanRemove",
    "page": "Events",
    "title": "Discord.GuildBanRemove",
    "category": "type",
    "text": "Sent when a User is unbanned from a Guild.\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.GuildEmojisUpdate",
    "page": "Events",
    "title": "Discord.GuildEmojisUpdate",
    "category": "type",
    "text": "Sent when a Guild has its Emojis updated.\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.GuildIntegrationsUpdate",
    "page": "Events",
    "title": "Discord.GuildIntegrationsUpdate",
    "category": "type",
    "text": "Sent when a Guild has its Integrations updated.\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.GuildMemberAdd",
    "page": "Events",
    "title": "Discord.GuildMemberAdd",
    "category": "type",
    "text": "Sent when a Member is added to a Guild.\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.GuildMemberRemove",
    "page": "Events",
    "title": "Discord.GuildMemberRemove",
    "category": "type",
    "text": "Sent when a Member is removed from a Guild.\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.GuildMemberUpdate",
    "page": "Events",
    "title": "Discord.GuildMemberUpdate",
    "category": "type",
    "text": "Sent when a Member is updated in a Guild.\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.GuildMembersChunk",
    "page": "Events",
    "title": "Discord.GuildMembersChunk",
    "category": "type",
    "text": "Sent when the Client requests guild members with request_guild_members.\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.GuildRoleCreate",
    "page": "Events",
    "title": "Discord.GuildRoleCreate",
    "category": "type",
    "text": "Sent when a new Role is created in a Guild.\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.GuildRoleUpdate",
    "page": "Events",
    "title": "Discord.GuildRoleUpdate",
    "category": "type",
    "text": "Sent when a Role is updated in a Guild.\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.GuildRoleDelete",
    "page": "Events",
    "title": "Discord.GuildRoleDelete",
    "category": "type",
    "text": "Sent when a Role is deleted from a Guild.\n\n\n\n\n\n"
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
    "text": "Sent when a Message is sent.\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.MessageUpdate",
    "page": "Events",
    "title": "Discord.MessageUpdate",
    "category": "type",
    "text": "Sent when a Message is updated.\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.MessageDelete",
    "page": "Events",
    "title": "Discord.MessageDelete",
    "category": "type",
    "text": "Sent when a Message is deleted.\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.MessageDeleteBulk",
    "page": "Events",
    "title": "Discord.MessageDeleteBulk",
    "category": "type",
    "text": "Sent when multiple Messages are deleted in bulk.\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.MessageReactionAdd",
    "page": "Events",
    "title": "Discord.MessageReactionAdd",
    "category": "type",
    "text": "Sent when a Reaction is added to a Message.\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.MessageReactionRemove",
    "page": "Events",
    "title": "Discord.MessageReactionRemove",
    "category": "type",
    "text": "Sent when a Reaction is removed from a Message.\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.MessageReactionRemoveAll",
    "page": "Events",
    "title": "Discord.MessageReactionRemoveAll",
    "category": "type",
    "text": "Sent when all Reactions are removed from a Message.\n\n\n\n\n\n"
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
    "text": "Sent when a User\'s Presence is updated.\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.TypingStart",
    "page": "Events",
    "title": "Discord.TypingStart",
    "category": "type",
    "text": "Sent when a User begins typing.\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.UserUpdate",
    "page": "Events",
    "title": "Discord.UserUpdate",
    "category": "type",
    "text": "Sent when a User\'s details are updated.\n\n\n\n\n\n"
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
    "text": "Sent when a User updates their VoiceState.\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.VoiceServerUpdate",
    "page": "Events",
    "title": "Discord.VoiceServerUpdate",
    "category": "type",
    "text": "Sent when a Guild\'s voice server is updated.\n\n\n\n\n\n"
},

{
    "location": "events.html#Voice-1",
    "page": "Events",
    "title": "Voice",
    "category": "section",
    "text": "VoiceStateUpdate\nVoiceServerUpdate"
},

{
    "location": "events.html#Discord.WebhookUpdate",
    "page": "Events",
    "title": "Discord.WebhookUpdate",
    "category": "type",
    "text": "Sent when a DiscordChannel\'s Webhooks are updated.\n\n\n\n\n\n"
},

{
    "location": "events.html#Webhooks-1",
    "page": "Events",
    "title": "Webhooks",
    "category": "section",
    "text": "WebhookUpdate"
},

{
    "location": "events.html#Discord.Ready",
    "page": "Events",
    "title": "Discord.Ready",
    "category": "type",
    "text": "Sent when the Client has successfully authenticated, and contains the initial state.\n\n\n\n\n\n"
},

{
    "location": "events.html#Discord.Resumed",
    "page": "Events",
    "title": "Discord.Resumed",
    "category": "type",
    "text": "Sent when a Client resumes its connection.\n\n\n\n\n\n"
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
    "location": "rest.html#Discord.Response",
    "page": "REST API",
    "title": "Discord.Response",
    "category": "type",
    "text": "A wrapper around a response from the REST API. Every function which wraps a Discord REST API endpoint returns a value of this type.\n\nFields\n\nval::Union{T, Nothing}: The object contained in the HTTP response. For example, a call to get_message will return a Response{Message} for which this value is a Message. If success is false, it is nothing.\nsuccess::Bool: The success state of the request. If this is true, then it is safe to access val.\ncache_hit::Bool: Whether val came from the cache.\nrate_limited::Bool: Whether the request was rate limited.\nhttp_response::Union{HTTP.Messages.Response, Nothing}: The underlying HTTP response. If no HTTP request was made (cache hit, rate limit, etc.), it is nothing.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Response-1",
    "page": "REST API",
    "title": "Response",
    "category": "section",
    "text": "Response"
},

{
    "location": "rest.html#Discord.OnLimit",
    "page": "REST API",
    "title": "Discord.OnLimit",
    "category": "type",
    "text": "Passed as a keyword argument to Client to determine the client\'s behaviour when it hits a rate limit. If set to LIMIT_IGNORE, a Response is returned immediately with rate_limited set to true. If set to LIMIT_WAIT, the client blocks until the rate limit resets, then retries the request.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Rate-Limiting-1",
    "page": "REST API",
    "title": "Rate Limiting",
    "category": "section",
    "text": "OnLimit"
},

{
    "location": "rest.html#Discord.get_message",
    "page": "REST API",
    "title": "Discord.get_message",
    "category": "function",
    "text": "get_message(\n    c::Client,\n    channel::Union{DiscordChannel, Integer},\n    message::Integer,\n) -> Response{Message}\nget_message(c::Client, m::Message) -> Response{Message}\n\nGet a Message from a DiscordChannel.\n\n\n\n\n\n"
},

{
    "location": "rest.html#Endpoints-1",
    "page": "REST API",
    "title": "Endpoints",
    "category": "section",
    "text": "get_messageTODO"
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
    "text": "A User activity. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.ActivityTimestamps",
    "page": "Types",
    "title": "Discord.ActivityTimestamps",
    "category": "type",
    "text": "Indicates the start and stop of an Activity. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.ActivityParty",
    "page": "Types",
    "title": "Discord.ActivityParty",
    "category": "type",
    "text": "The current party of an Activity\'s player. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.ActivityAssets",
    "page": "Types",
    "title": "Discord.ActivityAssets",
    "category": "type",
    "text": "Images and hover text for an Activity. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.ActivitySecrets",
    "page": "Types",
    "title": "Discord.ActivitySecrets",
    "category": "type",
    "text": "Secrets for Rich Presence joining and spectating of an Activity. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.ActivityType",
    "page": "Types",
    "title": "Discord.ActivityType",
    "category": "type",
    "text": "The type of an Activity. More details here.\n\n\n\n\n\n"
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
    "text": "A Message attachment. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.Ban",
    "page": "Types",
    "title": "Discord.Ban",
    "category": "type",
    "text": "A User ban. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.DiscordChannel",
    "page": "Types",
    "title": "Discord.DiscordChannel",
    "category": "type",
    "text": "A Discord channel. More details here. Note: The name Channel is already used, hence the prefix.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.ChannelType",
    "page": "Types",
    "title": "Discord.ChannelType",
    "category": "type",
    "text": "The type of a DiscordChannel.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.Connection",
    "page": "Types",
    "title": "Discord.Connection",
    "category": "type",
    "text": "A User connection to an external service (Twitch, YouTube, etc.). More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.Embed",
    "page": "Types",
    "title": "Discord.Embed",
    "category": "type",
    "text": "A Message embed. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.EmbedThumbnail",
    "page": "Types",
    "title": "Discord.EmbedThumbnail",
    "category": "type",
    "text": "An Embed\'s thumbnail image information. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.EmbedVideo",
    "page": "Types",
    "title": "Discord.EmbedVideo",
    "category": "type",
    "text": "An Embed\'s video information. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.EmbedImage",
    "page": "Types",
    "title": "Discord.EmbedImage",
    "category": "type",
    "text": "An Embed\'s image information. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.EmbedProvider",
    "page": "Types",
    "title": "Discord.EmbedProvider",
    "category": "type",
    "text": "An Embed\'s provider information. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.EmbedAuthor",
    "page": "Types",
    "title": "Discord.EmbedAuthor",
    "category": "type",
    "text": "An Embed\'s author information. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.EmbedFooter",
    "page": "Types",
    "title": "Discord.EmbedFooter",
    "category": "type",
    "text": "An Embed\'s footer information. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.EmbedField",
    "page": "Types",
    "title": "Discord.EmbedField",
    "category": "type",
    "text": "An Embed field. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.Emoji",
    "page": "Types",
    "title": "Discord.Emoji",
    "category": "type",
    "text": "An emoji. More details here.\n\n\n\n\n\n"
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
    "text": "A guild (server). More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.UnavailableGuild",
    "page": "Types",
    "title": "Discord.UnavailableGuild",
    "category": "type",
    "text": "An unavailable guild (server). More details here.\n\n\n\n\n\n"
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
    "text": "A Guild embed. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.Integration",
    "page": "Types",
    "title": "Discord.Integration",
    "category": "type",
    "text": "A Guild integration. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.IntegrationAccount",
    "page": "Types",
    "title": "Discord.IntegrationAccount",
    "category": "type",
    "text": "An Integration account. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.Invite",
    "page": "Types",
    "title": "Discord.Invite",
    "category": "type",
    "text": "An invite to a Guild. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.InviteMetadata",
    "page": "Types",
    "title": "Discord.InviteMetadata",
    "category": "type",
    "text": "Metadata for an Invite. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.Member",
    "page": "Types",
    "title": "Discord.Member",
    "category": "type",
    "text": "A Guild member. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.Message",
    "page": "Types",
    "title": "Discord.Message",
    "category": "type",
    "text": "A message. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.MessageActivity",
    "page": "Types",
    "title": "Discord.MessageActivity",
    "category": "type",
    "text": "A Message activity. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.MessageApplication",
    "page": "Types",
    "title": "Discord.MessageApplication",
    "category": "type",
    "text": "A Rich Presence Message\'s application information. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.MessageType",
    "page": "Types",
    "title": "Discord.MessageType",
    "category": "type",
    "text": "The type of a Message. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.MessageActivityType",
    "page": "Types",
    "title": "Discord.MessageActivityType",
    "category": "type",
    "text": "The type of a Message activity. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.Overwrite",
    "page": "Types",
    "title": "Discord.Overwrite",
    "category": "type",
    "text": "A permission overwrite. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.Presence",
    "page": "Types",
    "title": "Discord.Presence",
    "category": "type",
    "text": "A User\'s presence. More details here.\n\n\n\n\n\n"
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
    "text": "A Message reaction. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.Role",
    "page": "Types",
    "title": "Discord.Role",
    "category": "type",
    "text": "A User role. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.User",
    "page": "Types",
    "title": "Discord.User",
    "category": "type",
    "text": "A Discord user. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.VoiceRegion",
    "page": "Types",
    "title": "Discord.VoiceRegion",
    "category": "type",
    "text": "A region for a Guild\'s voice server. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.VoiceState",
    "page": "Types",
    "title": "Discord.VoiceState",
    "category": "type",
    "text": "A User\'s voice connection status. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.Webhook",
    "page": "Types",
    "title": "Discord.Webhook",
    "category": "type",
    "text": "A Webhook. More details here.\n\n\n\n\n\n"
},

{
    "location": "types.html#Types-1",
    "page": "Types",
    "title": "Types",
    "category": "section",
    "text": "This page is organized in mostly-alphabetical order.Activity\nActivityTimestamps\nActivityParty\nActivityAssets\nActivitySecrets\nActivityType\nActivityFlags\nAttachment\nBan\nDiscordChannel\nChannelType\nConnection\nEmbed\nEmbedThumbnail\nEmbedVideo\nEmbedImage\nEmbedProvider\nEmbedAuthor\nEmbedFooter\nEmbedField\nEmoji\nAbstractGuild\nGuild\nUnavailableGuild\nVerificationLevel\nMessageNotificationLevel\nExplicitContentFilterLevel\nMFALevel\nGuildEmbed\nIntegration\nIntegrationAccount\nInvite\nInviteMetadata\nMember\nMessage\nMessageActivity\nMessageApplication\nMessageType\nMessageActivityType\nOverwrite\nPresence\nPresenceStatus\nReaction\nRole\nUser\nVoiceRegion\nVoiceState\nWebhook"
},

]}
