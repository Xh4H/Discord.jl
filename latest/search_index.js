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
    "text": "Client(token::String; on_limit::OnLimit=LIMIT_IGNORE, ttl::Period=Hour(1) -> Client\n\nA Discord bot.\n\nKeywords\n\non_limit::OnLimit=LIMIT_IGNORE: Client\'s behaviour when it hits a rate limit.\nttl::Period=Hour(1) Amount of time that cache entries are kept.\nversion::Int=6: Version of Discord API to use. Using anything but 6 is not supported.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.UnknownEvent",
    "page": "Reference",
    "title": "Julicord.UnknownEvent",
    "category": "type",
    "text": "An unknown event.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.add_handler!-Tuple{Client,Type{#s355} where #s355<:AbstractEvent,Function}",
    "page": "Reference",
    "title": "Julicord.add_handler!",
    "category": "method",
    "text": "add_handler!(\n    c::Client,\n    evt::Type{<:AbstractEvent},\n    func::Function;\n    tag::Symbol=gensym(),\n    expiry::Union{Int, Period}=-1,\n)\n\nAdd a handler for the given event type. The handler should be a function which takes two arguments: A Client and an AbstractEvent (or a subtype). The handler is appended the event\'s current handlers.\n\nKeywords\n\ntag::Symbol=gensym(): A label for the handler, which can be used to remove it with delete_handler!.\nexpiry::Union{Int, Period}=-1: The handler\'s expiry. If an Int is given, the handler\n\nwill run a set number of times before expiring. If a Period is given, the handler will expire after that amount of time has elapsed. The default of -1 indicates no expiry.\n\nnote: Note\nThere is no guarantee on the order in which handlers run, except that catch-all handlers run before specific ones.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.add_role-Tuple{Client,Integer,Integer,Integer}",
    "page": "Reference",
    "title": "Julicord.add_role",
    "category": "method",
    "text": "add_role(\n    c::Client,\n    guild::Union{AbstractGuild, Integer},\n    user::Union{User, Integer},\n    role::Union{Role, Integer},\n) -> Response\n\nAdd a Role to a Member in an AbstractGuild..\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.ban_member-Tuple{Client,Integer,Integer}",
    "page": "Reference",
    "title": "Julicord.ban_member",
    "category": "method",
    "text": "ban_member(\n    c::Client,\n    guild::Union{Guild, Integer},\n    user::Union{User, Integer};\n    params...,\n) -> Response\n\nBan a Member from an AbstractGuild.\n\nKeywords\n\ndelete_message_days::Integer: Number of days to delete the messages for (0-7).\nreason::AbstractString: Reason for the ban.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.bulk_delete-Tuple{Client,Integer,Array{#s358,1} where #s358<:Integer}",
    "page": "Reference",
    "title": "Julicord.bulk_delete",
    "category": "method",
    "text": "bulk_delete(\n    c::Client,\n    channel::Union{DiscordChannel, Integer},\n    messages::Union{Vector{Message}, Vector{<:Integer}},\n) -> Response\n\nDelete multiple Messages from a DiscordChannel.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.clear_handlers!-Tuple{Client,Type{#s358} where #s358<:AbstractEvent}",
    "page": "Reference",
    "title": "Julicord.clear_handlers!",
    "category": "method",
    "text": "clear_handlers!(c::Client, evt::Type{<:AbstractEvent})\n\nRemove all handlers for the given event type. Using this is generally not recommended because it also clears default handlers which maintain the client state. Instead, try to add handlers with specific tags and delete them with delete_handler!.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.create_invite-Tuple{Client,Integer,Vararg{Any,N} where N}",
    "page": "Reference",
    "title": "Julicord.create_invite",
    "category": "method",
    "text": "create_invite(\n    c::Client,\n    channel::Union{DiscordChannel, Integer};\n    params...,\n) -> Response{Invite}\n\nCreate an Invite to a DiscordChannel.\n\nKeywords\n\nmax_uses::Int: Max number of uses (0 if unlimited).\nmax_age::Int: Duration in seconds before expiry (0 if never).\ntemporary::Bool: Whether this invite only grants temporary membership.\nunique::Bool: Whether not to try to reuse a similar invite.\n\nMore details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.create_webhook-Tuple{Client,Integer,Vararg{Any,N} where N}",
    "page": "Reference",
    "title": "Julicord.create_webhook",
    "category": "method",
    "text": "create_webhook(\n    c::Client,\n    channel::Union{DiscordChannel, Integer},\n    params...,\n) -> Response\n\nCreate a Webhook in a DiscordChannel.\n\nKeywords\n\nname::AbstractString - name of the webhook (2-23 characters)\navatar::AbstractString - image for the default webhook avatar\n\nMore details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.delete-Tuple{Client,Julicord.Message}",
    "page": "Reference",
    "title": "Julicord.delete",
    "category": "method",
    "text": "delete(c::Client, m::Message) -> Response\n\nDelete a Message.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.delete_channel-Tuple{Client,Integer}",
    "page": "Reference",
    "title": "Julicord.delete_channel",
    "category": "method",
    "text": "delete_channel(c::Client, channel:::Union{DiscordChannel, Integer}) -> Response{Channel}\n\nDelete a DiscordChannel.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.delete_handler!-Tuple{Client,Type{#s358} where #s358<:AbstractEvent,Symbol}",
    "page": "Reference",
    "title": "Julicord.delete_handler!",
    "category": "method",
    "text": "delete_handler!(c::Client, evt::Type{<:AbstractEvent}, tag::Symbol)\n\nDelete a single handler by event type and tag.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.delete_integration-Tuple{Client,Integer,Integer}",
    "page": "Reference",
    "title": "Julicord.delete_integration",
    "category": "method",
    "text": "delete_integration(\n    c::Client,\n    guild::Union{AbstractGuild, Integer},\n    integration::Union{Integration, Integer},\n) -> Response\n\nDelete an Integration in an AbstractGuild.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.delete_invite-Tuple{Client,AbstractString}",
    "page": "Reference",
    "title": "Julicord.delete_invite",
    "category": "method",
    "text": "delete_invite(c::Client, invite::Union{Invite, AbstractString}) -> Response{Invite}\n\nDelete an Invite.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.delete_overwrite-Tuple{Client,Integer,Integer}",
    "page": "Reference",
    "title": "Julicord.delete_overwrite",
    "category": "method",
    "text": "delete_overwrite(\n    c::Client,\n    overwrite::Union{Overwrite, Integer},\n    channel::Union{DiscordChannel, Integer}\n) -> Response{Overwrite}\n\nDelete an Overwrite in a DiscordChannel.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.delete_reactions-Tuple{Client,Julicord.Message}",
    "page": "Reference",
    "title": "Julicord.delete_reactions",
    "category": "method",
    "text": "delete_reactions(c::Client, m::Message) -> Response\n\nDelete all the reactions from a Message.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.delete_role-Tuple{Client,Integer,Integer}",
    "page": "Reference",
    "title": "Julicord.delete_role",
    "category": "method",
    "text": "delete_role(\n    c::Client,\n    role::Union{Role, Integer},\n    guild::Union{AbstractGuild, Integer},\n) -> Response\n\nModify a Role in a DiscordChannel.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.delete_webhook-Tuple{Client,Integer}",
    "page": "Reference",
    "title": "Julicord.delete_webhook",
    "category": "method",
    "text": "delete_webhook(c::Client, webhook::Union{Webhook, Integer}) -> Response\ndelete_webhook(\n    c::Client,\n    webhook::Union{Webhook, Integer},\n    token::AbstractString,\n) -> Response\n\nDelete a Webhook.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.edit-Tuple{Client,Julicord.Message,AbstractDict}",
    "page": "Reference",
    "title": "Julicord.edit",
    "category": "method",
    "text": "edit(c::Client, m::Message, content::Union{AbstractString, Dict}) -> Response{Message}\n\nEdit a Message.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.execute_github-Tuple{Client,Integer,AbstractString}",
    "page": "Reference",
    "title": "Julicord.execute_github",
    "category": "method",
    "text": "execute_github(\n    c::Client,\n    webhook::Union{Webhook, Integer},\n    token::AbstractString;\n    wait::Bool=true,\n    params...,\n) -> Union{Response{Message}, Response{Nothing}}\n\nExecute a Github Webhook.\n\nMore details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.execute_slack-Tuple{Client,Integer,AbstractString}",
    "page": "Reference",
    "title": "Julicord.execute_slack",
    "category": "method",
    "text": "execute_slack(\n    c::Client,\n    webhook::Union{Webhook, Integer},\n    token::AbstractString;\n    wait::Bool=true,\n    params...,\n) -> Union{Response{Message}, Response}\n\nExecute a Slack Webhook.\n\nMore details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.execute_webhook-Tuple{Client,Integer,AbstractString}",
    "page": "Reference",
    "title": "Julicord.execute_webhook",
    "category": "method",
    "text": "execute_webhook(\n    c::Client,\n    webhook::Union{Webhook, Integer},\n    token::AbstractString;\n    wait::Bool=false,\n    params...,\n) -> Union{Response{Message}, Response{Nothing}}\n\nExecute a Webhook. If wait is set, the created Message is returned.\n\nKeywords\n\ncontent::AbstractString: The message contents (up to 2000 characters).\nusername::AbstractString: Override the default username of the webhook.\navatar_url::AbstractString: Override the default avatar of the webhook.\ntts::Bool: Whether this is a TTS message.\nfile::AbstractDict: The contents of the file being sent.\nembeds::AbstractDict: Embedded rich content.\n\nMore details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.get_invite-Tuple{Client,AbstractString}",
    "page": "Reference",
    "title": "Julicord.get_invite",
    "category": "method",
    "text": "get_invite(\n    c::Client,\n    invite::Union{Invite, AbstractString};\n    with_counts::Bool=false,\n) -> Response{Invite}\n\nGet an Invite. If with_counts is set, the Invite will contain approximate member counts.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.get_invites-Tuple{Client,Integer}",
    "page": "Reference",
    "title": "Julicord.get_invites",
    "category": "method",
    "text": "get_invites(\n    c::Client,\n    channel::Union{DiscordChannel, Integer},\n) -> Response{Vector{Invite}}\n\nGet a list of Invites from a DiscordChannel.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.get_member-Tuple{Client,Integer,Integer}",
    "page": "Reference",
    "title": "Julicord.get_member",
    "category": "method",
    "text": "get_member(\n    c::Client,\n    guild::Union{AbstractGuild, Integer},\n    user::Union{User, Integer},\n) -> Response{Member}\n\nGet a Member in an AbstractGuild.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.get_message-Tuple{Client,Integer,Integer}",
    "page": "Reference",
    "title": "Julicord.get_message",
    "category": "method",
    "text": "get_message(\n    c::Client,\n    channel::Union{DiscordChannel, Integer},\n    message::Integer,\n) -> Response{Message}\nget_message(c::Client, m::Message) -> Response{Message}\n\nGet a Message from a DiscordChannel.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.get_messages-Tuple{Client,Integer}",
    "page": "Reference",
    "title": "Julicord.get_messages",
    "category": "method",
    "text": "get_messages(\n    c::Client,\n    channel::Union{DiscordChannel, Integer};\n    params...,\n) -> Response{Vector{Message}}\n\nGet a list of Messages from a DiscordChannel.\n\nKeywords\n\naround::Integer: Get messages around this message ID.\nbefore::Integer: Get messages before this message ID.\nafter::Integer: Get messages after this message ID.\nlimit::Int: Maximum number of messages.\n\nMore details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.get_pinned_messages-Tuple{Client,Integer}",
    "page": "Reference",
    "title": "Julicord.get_pinned_messages",
    "category": "method",
    "text": "get_pinned_messages(\n    c::Client,\n    channel::Union{DiscordChannel, Integer},\n) -> Response{Vector{Message}}\n\nGet a list of Messages pinned in a DiscordChannel.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.get_reactions-Tuple{Client,Julicord.Message,AbstractString}",
    "page": "Reference",
    "title": "Julicord.get_reactions",
    "category": "method",
    "text": "get_reactions(\n    c::Client,\n    m::Message,\n    emoji::Union{Emoji, AbstractString},\n) -> Response{Vector{User}}\n\nGet the users who reacted to a Message with an Emoji.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.get_webhook-Tuple{Client,Integer}",
    "page": "Reference",
    "title": "Julicord.get_webhook",
    "category": "method",
    "text": "get_webhook(c::Client, webhook::Union{Webhook, Integer}) -> Response{Webhook}\nget_webhook(\n    c::Client,\n    webhook::Union{Webhook, Integer},\n    token::AbstractString,\n) -> Response{Webhook}\n\nGet a Webhook.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.get_webhooks-Tuple{Client,Integer}",
    "page": "Reference",
    "title": "Julicord.get_webhooks",
    "category": "method",
    "text": "get_webhooks(\n    c::Client,\n    channel::Union{DiscordChannel, Integer},\n) -> Response{Vector{Webhook}}\n\nGet a list of Webhooks from a DiscordChannel.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.kick_member-Tuple{Client,Integer,Integer}",
    "page": "Reference",
    "title": "Julicord.kick_member",
    "category": "method",
    "text": "kick_member(\n    c::Client,\n    guild::Union{AbstractGuild, Integer},\n    user::Union{User, Integer},\n) -> Response\n\nKick a Member from an AbstractGuild.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.me-Tuple{Client}",
    "page": "Reference",
    "title": "Julicord.me",
    "category": "method",
    "text": "me(c::Client) -> Union{User, Nothing}\n\nGet the client\'s bot user.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.modify_channel-Tuple{Client,Integer}",
    "page": "Reference",
    "title": "Julicord.modify_channel",
    "category": "method",
    "text": "modify_channel(\n    c::Client,\n    channel::Union{DiscordChannel, Integer};\n    params...,\n) -> Response{Channel}\n\nModify a DiscordChannel.\n\nKeywords\n\nname::AbstractString: Channel name (2-100 characters).\ntopic::AbstractString: Channel topic (up to 1024 characters).\nnsfw::Bool: Whether the channel is NSFW.\nrate_limit_per_user::Int: Seconds a user must wait before sending another message.\nposition::Int The position in the left-hand listing.\nbitrate::Int The bitrate in bits of the voice channel.\nuser_limit::Int: The user limit of the voice channel.\npermission_overwrites::Vector{<:AbstractDict}: Channel or category-specific permissions.\nparent_id::Integer: ID of the new parent category.\n\nMore details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.modify_integration-Tuple{Client,Integer,Integer}",
    "page": "Reference",
    "title": "Julicord.modify_integration",
    "category": "method",
    "text": "modify_integration(\n    c::Client,\n    guild::Union{AbstractGuild, Integer},\n    integration::Union{Integration, Integer};\n    params...,\n) -> Response{Integration}\n\nModify an Integration in an AbstractGuild.\n\nKeywords\n\nexpire_behavior::Integer: The behavior when an integration subscription lapses.\nexpire_grace_period::Integer: Period (in seconds) where the integration will ignore lapsed subscriptions.\nenable_emoticons::Bool: Whether emoticons should be synced for this integration (Twitch  only currently).\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.modify_member-Tuple{Client,Integer,Integer}",
    "page": "Reference",
    "title": "Julicord.modify_member",
    "category": "method",
    "text": "modify_member(\n    c::Client,\n    guild::Union{AbstractGuild, Integer},\n    user::Union{User, Integer};\n    params...,\n) -> Response{Member}\n\nModify a Member in an AbstractGuild.\n\nKeywords\n\nnick::AbstractString: Value to set the member\'s nickname to.\nroles::Vector: List of role ids the member is assigned.\nmute::Bool: Whether the member should be muted.\ndeaf::Bool: Whether the member should be deafened.\nchannel_id::Integer: ID of a voice channel to move the member to.\n\nMore details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.modify_overwrite-Tuple{Client,Integer,Integer}",
    "page": "Reference",
    "title": "Julicord.modify_overwrite",
    "category": "method",
    "text": "modify_overwrite(\n    c::Client,\n    overwrite::Union{Overwrite, Integer},\n    channel::Union{DiscordChannel, Integer};\n    params...,\n) -> Response{Overwrite}\n\nModify an Overwrite in a DiscordChannel.\n\nKeywords\n\nallow::Int: the bitwise OR of the allowed permissions.\ndeny::Int: the bitwise OR of the denied permissions.\ntype::AbstractString: \"member\" for a user or \"role\" for a role.\n\nMore details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.modify_role-Tuple{Client,Integer,Integer}",
    "page": "Reference",
    "title": "Julicord.modify_role",
    "category": "method",
    "text": "modify_role(\n    c::Client,\n    role::Union{Role, Integer},\n    guild::Union{AbstractGuild, Integer};\n    params...,\n) -> Response{Role}\n\nModify a Role in a DiscordChannel.\n\nKeywords\n\nname::AbstractString: Name of the role.\npermissions::Int: Bitwise OR of the enabled/disabled permissions.\ncolor::Int: RGB color value.\nhoist::Bool: Whether the role should be displayed separately in the sidebar.\nmentionable::Bool: Whether the role should be mentionable.\n\nMore details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.modify_webhook-Tuple{Client,Integer}",
    "page": "Reference",
    "title": "Julicord.modify_webhook",
    "category": "method",
    "text": "modify_webhook(c::Client, webhook::Union{Webhook, Integer}; params...) -> Response{Webhook}\nmodify_webhook(\n    c::Client,\n    webhook::Union{Webhook, Integer},\n    token::AbstractString;\n    params...,\n) -> Response{Webhook}\n\nModify a Webhook.\n\nKeywords\n\nname::AbstractString: Name of the webhook.\navatar::AbstractString: Avatar data string.\nchannel_id::Integer: The channel this webhook should be moved to.\n\nIf using a token, channel_id cannot be used and the returned Webhook will not contain a User.\n\nMore details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.pin-Tuple{Client,Julicord.Message}",
    "page": "Reference",
    "title": "Julicord.pin",
    "category": "method",
    "text": "pin(c::Client, m::Message) -> Response\n\nPin a Message.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.react-Tuple{Client,Julicord.Message,AbstractString}",
    "page": "Reference",
    "title": "Julicord.react",
    "category": "method",
    "text": "react(c::Client, m::Message, emoji::AbstractString) -> Response\n\nReact to a Message.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.remove_role-Tuple{Client,Integer,Integer,Integer}",
    "page": "Reference",
    "title": "Julicord.remove_role",
    "category": "method",
    "text": "remove_role(\n    c::Client,\n    guild::Union{AbstractGuild, Integer},\n    user::Union{User, Integer},\n    role::Union{Role, Integer},\n) -> Response\n\nRemove a Role from a Member in an AbstractGuild.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.reply-Tuple{Client,Julicord.Message,Union{AbstractString, Dict}}",
    "page": "Reference",
    "title": "Julicord.reply",
    "category": "method",
    "text": "reply(c::Client, m::Message, content::Union{AbstractString, Dict}) -> Response{Message}\n\nReply to a Message (send a message to the same channel).\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.request_guild_members-Tuple{Client,UInt64}",
    "page": "Reference",
    "title": "Julicord.request_guild_members",
    "category": "method",
    "text": "request_guild_members(\n    c::Client,\n    guild_id::Union{Snowflake, Vector{Snowflake};\n    query::AbstractString=\"\",\n    limit::Int=0,\n) -> Bool\n\nRequest offline guild members of one or more guilds. More details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.send_message-Tuple{Client,Integer,AbstractDict}",
    "page": "Reference",
    "title": "Julicord.send_message",
    "category": "method",
    "text": "send_message(\n    c::Client,\n    channel::Union{DiscordChannel, Integer},\n    content::Union{AbstractString, AbstractDict},\n) -> Response{Message}\n\nSend a Message to a DiscordChannel.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.state-Tuple{Client}",
    "page": "Reference",
    "title": "Julicord.state",
    "category": "method",
    "text": "state(c::Client) -> State\n\nGet the client state.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.sync_integration-Tuple{Client,Integer,Integer}",
    "page": "Reference",
    "title": "Julicord.sync_integration",
    "category": "method",
    "text": "sync_integration(\n    c::Client,\n    guild::Union{Guild, Integer},\n    integration::Union{Integration, Integer},\n) -> Response\n\nSync an Integration in an AbstractGuild.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.trigger_typing-Tuple{Client,Integer}",
    "page": "Reference",
    "title": "Julicord.trigger_typing",
    "category": "method",
    "text": "trigger_typing(c::Client, channel::Union{DiscordChannel, Integer}) -> Response\n\nTrigger the typing indicator in a DiscordChannel.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.unpin-Tuple{Client,Julicord.Message}",
    "page": "Reference",
    "title": "Julicord.unpin",
    "category": "method",
    "text": "unpin(c::Client, m::Message) -> Response\n\nUnpin a Message.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.update_status-Tuple{Client,Union{Nothing, Int64},Union{Nothing, Activity},Julicord.PresenceStatus,Bool}",
    "page": "Reference",
    "title": "Julicord.update_status",
    "category": "method",
    "text": "update_status(\n    c::Client,\n    since::Union{Int, Nothing},\n    activity::Union{Activity, Nothing},\n    status::PresenceStatus,\n    afk::Bool,\n) -> Bool\n\nIndicate a presence or status update. More details here.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.AbstractGuild",
    "page": "Reference",
    "title": "Julicord.AbstractGuild",
    "category": "type",
    "text": "A guild (server). Can either be an UnavailableGuild or a Guild.\n\n\n\n\n\n"
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
    "location": "reference.html#Julicord.OnLimit",
    "page": "Reference",
    "title": "Julicord.OnLimit",
    "category": "type",
    "text": "Determines the behaviour of a Client when it hits a rate limit. If set to LIMIT_IGNORE, a Response is returned immediately with rate_limited set to true. If set to LIMIT_WAIT, the client blocks until the rate limit resets, then retries the request.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Julicord.Overwrite-Tuple{Dict{String,Any}}",
    "page": "Reference",
    "title": "Julicord.Overwrite",
    "category": "method",
    "text": "An Overwrite. More details here.\n\n\n\n\n\n"
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
    "location": "reference.html#Julicord.Response",
    "page": "Reference",
    "title": "Julicord.Response",
    "category": "type",
    "text": "A wrapper around a response from the REST API.\n\nFields\n\nval::Union{T, Nothing}: The object contained in the HTTP response. For example, a call to get_message will return a Response{Message} for which this value is a Message. If success is false, it is nothing.\nsuccess::Bool: The success state of the request. If this is true, then it is safe to access val.\ncache_hit::Bool: Whether val came from the cache.\nrate_limited::Bool: Whether the request was rate limited.\nhttp_response::Union{HTTP.Messages.Response, Nothing}: The underlying HTTP response. If success is true, it is nothing.\n\n\n\n\n\n"
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
