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
    "text": "Client(\n    token::String;\n    on_limit::OnLimit=LIMIT_IGNORE,\n    ttl::Period=Hour(1),\n    version::Int=6\n ) -> Client\n\nA Discord bot. Clients can connect to the gateway, respond to events, and make REST API calls to perform actions such as sending/deleting messages, kicking/banning users, etc.\n\nTo get a bot token, head here to create a new application. Once you\'ve created a bot user, you will have access to its token.\n\nKeywords\n\non_limit::OnLimit=LIMIT_IGNORE: Client\'s behaviour when it hits a rate limit (see \"Rate Limiting\" below for more details).\nttl::Period=Hour(1) Amount of time that cache entries are kept (see \"Caching\" below for more details).\nversion::Int=6: Version of the Discord API to use. Using anything but 6 is not officially supported by the Discord.jl developers.\n\nCaching\n\nBy default, most data that comes from Discord is cached for later use. However, to avoid memory leakage, it\'s deleted after some time (determined by the ttl keyword). Although it\'s not recommended, you can also disable caching of certain data by clearing default handlers for relevant event types with clear_handlers!. For example, if you wanted to avoid caching any messages, you would clear handlers for MessageCreate and MessageUpdate events.\n\nRate Limiting\n\nDiscord enforces rate limits on usage of its REST API. This  means you can  only send so many messages in a given period, and so on. To customize the client\'s behaviour when encountering rate limits, use the on_limit keyword and see OnLimit.\n\nSharding\n\nSharding is handled automatically: The number of available processes is the number of shards that are created. See the sharding example for more details.\n\n\n\n\n\n"
},

{
    "location": "client.html#Base.open",
    "page": "Client",
    "title": "Base.open",
    "category": "function",
    "text": "open(c::Client; delay::Period=Second(7))\n\nConnect to the Discord gateway and begin responding to events.\n\nThe delay keyword is the number of seconds between shards connecting. It can be increased from its default if you are frequently experiencing invalid sessions upon connection.\n\n\n\n\n\n"
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
    "text": "add_handler!(\n    c::Client,\n    evt::Type{<:AbstractEvent},\n    func::Function;\n    tag::Symbol=gensym(),\n    expiry::Union{Int, Period}=-1\n)\n\nAdd a handler for an event type. The handler should be a function which takes two arguments: A Client and an AbstractEvent (or a subtype). The handler is appended the event\'s current handlers.\n\nKeywords\n\ntag::Symbol=gensym(): A label for the handler, which can be used to remove it with delete_handler!.\nexpiry::Union{Int, Period}=-1: The handler\'s expiry. If an Int is given, the handler will run a set number of times before expiring. If a Period is given, the handler will expire after that amount of time has elapsed. The default of -1 indicates no expiry.\n\nnote: Note\nThere is no guarantee on the order in which handlers run, except that catch-all (AbstractEvent) handlers run before specific ones.\n\n\n\n\n\n"
},

{
    "location": "client.html#Discord.add_command!",
    "page": "Client",
    "title": "Discord.add_command!",
    "category": "function",
    "text": "add_command!(\n    c::Client,\n    prefix::AbstractString,\n    func::Function;\n    tag::Symbol=gensym(),\n    expiry::Union{Int, Period}=-1\n)\n\nAdd a text command handler. The handler function should take two arguments: A Client and a Message. The keyword arguments are identical to add_handler!.\n\n\n\n\n\n"
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
    "text": "request_guild_members(\n    c::Client,\n    guild_id::Union{Snowflake, Vector{Snowflake};\n    query::AbstractString=\"\",\n    limit::Int=0\n) -> Bool\n\nRequest offline guild members of one or more guilds. GuildMembersChunk events are sent by the gateway in response.\n\nMore details here.\n\n\n\n\n\n"
},

{
    "location": "client.html#Discord.update_voice_state",
    "page": "Client",
    "title": "Discord.update_voice_state",
    "category": "function",
    "text": "update_voice_state(\n    c::Client,\n    guild_id::Snowflake,\n    channel_id::Union{Snowflake, Nothing},\n    self_mute::Bool,\n    self_deaf::Bool\n) -> Bool\n\nJoin, move, or disconnect from a voice channel. A VoiceStateUpdate event is sent by the gateway in response.\n\nMore details here.\n\n\n\n\n\n"
},

{
    "location": "client.html#Discord.update_status",
    "page": "Client",
    "title": "Discord.update_status",
    "category": "function",
    "text": "update_status(\n    c::Client,\n    since::Union{Int, Nothing},\n    activity::Union{Activity, Nothing},\n    status::PresenceStatus,\n    afk::Bool\n) -> Bool\n\nIndicate a presence or status update. A PresenceUpdate event is sent by the gateway in response.\n\nMore details here.\n\n\n\n\n\n"
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
    "text": "Note that Snowflake === UInt64. Unions with Nothing indicate that a field is nullable, whereas Unions with Missing indicate that a field is optional. More details here.AbstractEvent\nUnknownEvent"
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
    "text": "Sent when a guild is deleted, and contains an UnavailableGuild.\n\nFields\n\nguild :: UnavailableGuild\n\n\n\n\n\n"
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
    "location": "events.html#Discord.WebhookUpdate",
    "page": "Events",
    "title": "Discord.WebhookUpdate",
    "category": "type",
    "text": "Sent when a DiscordChannel\'s Webhooks are updated.\n\nFields\n\nguild_id   :: UInt64\nchannel_id :: UInt64\n\n\n\n\n\n"
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
    "text": "A User activity. More details here.\n\nFields\n\nname           :: String\ntype           :: ActivityType\nurl            :: Union{Missing, Nothing, String}\ntimestamps     :: Union{Missing, ActivityTimestamps}\napplication_id :: Union{Missing, UInt64}\ndetails        :: Union{Missing, Nothing, String}\nstate          :: Union{Missing, Nothing, String}\nparty          :: Union{Missing, ActivityParty}\nassets         :: Union{Missing, ActivityAssets}\nsecrets        :: Union{Missing, ActivitySecrets}\ninstance       :: Union{Missing, Bool}\nflags          :: Union{Missing, Int64}\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.ActivityTimestamps",
    "page": "Types",
    "title": "Discord.ActivityTimestamps",
    "category": "type",
    "text": "Indicates the start and stop of an Activity. More details here.\n\nFields\n\nstart :: Union{Missing, DateTime}\nstop  :: Union{Missing, DateTime}\n\n\n\n\n\n"
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
    "text": "Optional information in an AuditLogEntry.\n\nFields\n\ndelete_member_days :: Union{Missing, String}\nmembers_removed    :: Union{Missing, String}\nchannel_id         :: Union{Missing, UInt64}\ncount              :: Union{Missing, String}\nid                 :: Union{Missing, UInt64}\ntype               :: Union{Missing, String}\nrole_name          :: Union{Missing, String}\n\n\n\n\n\n"
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
    "text": "The type of a DiscordChannel.\n\n\n\n\n\n"
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
    "text": "A guild (server). More details here.\n\nFields\n\nid                            :: UInt64\nname                          :: String\nicon                          :: Union{Nothing, String}\nsplash                        :: Union{Nothing, String}\nowner                         :: Union{Missing, Bool}\nowner_id                      :: UInt64\npermissions                   :: Union{Missing, Int64}\nregion                        :: String\nafk_channel_id                :: Union{Nothing, UInt64}\nafk_timeout                   :: Int64\nembed_enabled                 :: Union{Missing, Bool}\nembed_channel_id              :: Union{Missing, UInt64}\nverification_level            :: VerificationLevel\ndefault_message_notifications :: MessageNotificationLevel\nexplicit_content_filter       :: ExplicitContentFilterLevel\nroles                         :: Array{Role,1}\nemojis                        :: Array{Emoji,1}\nfeatures                      :: Array{String,1}\nmfa_level                     :: MFALevel\napplication_id                :: Union{Nothing, UInt64}\nwidget_enabled                :: Union{Missing, Bool}\nwidget_channel_id             :: Union{Missing, UInt64}\nsystem_channel_id             :: Union{Nothing, UInt64}\njoined_at                     :: Union{Missing, DateTime}\nlarge                         :: Union{Missing, Bool}\nunavailable                   :: Union{Missing, Bool}\nmember_count                  :: Union{Missing, Int64}\nvoice_states                  :: Union{Missing, Array{VoiceState,1}}\nmembers                       :: Union{Missing, Array{Member,1}}\nchannels                      :: Union{Missing, Array{DiscordChannel,1}}\npresences                     :: Union{Missing, Array{Presence,1}}\n\n\n\n\n\n"
},

{
    "location": "types.html#Discord.UnavailableGuild",
    "page": "Types",
    "title": "Discord.UnavailableGuild",
    "category": "type",
    "text": "An unavailable guild (server). More details here.\n\nFields\n\nid          :: UInt64\nunavailable :: Bool\n\n\n\n\n\n"
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
    "text": "A Guild integration. More details here.\n\nFields\n\nid                  :: UInt64\nname                :: String\n_type               :: String\nenabled             :: Bool\nsyncing             :: Bool\nrole_id             :: UInt64\nexpire_behaviour    :: Int64\nexpire_grace_period :: Int64\nuser                :: User\naccount             :: IntegrationAccount\nsynced_at           :: Dates.DateTime\n\n\n\n\n\n"
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
    "text": "A permission overwrite. More details here.\n\nFields\n\nid    :: UInt64\ntype  :: String\nallow :: Int64\ndeny  :: Int64\n\n\n\n\n\n"
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
    "text": "This page is organized in mostly-alphabetical order. Note that Snowflake ===  UInt64. Unions with Nothing indicate that a field is nullable, whereas Unions with Missing indicate that a field is optional. More details here.Activity\nActivityTimestamps\nActivityParty\nActivityAssets\nActivitySecrets\nActivityType\nActivityFlags\nAttachment\nAuditLog\nAuditLogEntry\nAuditLogChange\nAuditLogOptions\nActionType\nBan\nDiscordChannel\nChannelType\nConnection\nEmbed\nEmbedThumbnail\nEmbedVideo\nEmbedImage\nEmbedProvider\nEmbedAuthor\nEmbedFooter\nEmbedField\nEmoji\nAbstractGuild\nGuild\nUnavailableGuild\nVerificationLevel\nMessageNotificationLevel\nExplicitContentFilterLevel\nMFALevel\nGuildEmbed\nIntegration\nIntegrationAccount\nInvite\nInviteMetadata\nMember\nMessage\nMessageActivity\nMessageApplication\nMessageType\nMessageActivityType\nOverwrite\nPresence\nPresenceStatus\nReaction\nRole\nUser\nVoiceRegion\nVoiceState\nWebhook"
},

]}
