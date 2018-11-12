export PERM_CREATE_INSTANT_INVITE,
    PERM_KICK_MEMBERS,
    PERM_BAN_MEMBERS,
    PERM_ADMINISTRATOR,
    PERM_MANAGE_CHANNELS,
    PERM_MANAGE_GUILD,
    PERM_ADD_REACTIONS,
    PERM_VIEW_AUDIT_LOG,
    PERM_VIEW_CHANNEL,
    PERM_SEND_MESSAGES,
    PERM_SEND_TTS_MESSAGES,
    PERM_MANAGE_MESSAGES,
    PERM_EMBED_LINKS,
    PERM_ATTACH_FILES,
    PERM_READ_MESSAGE_HISTORY,
    PERM_MENTION_EVERYONE,
    PERM_USE_EXTERNAL_EMOJIS,
    PERM_CONNECT,
    PERM_SPEAK,
    PERM_MUTE_MEMBERS,
    PERM_DEAFEN_MEMBERS,
    PERM_MOVE_MEMBERS,
    PERM_USE_VAD,
    PERM_PRIORITY_SPEAKER,
    PERM_CHANGE_NICKNAME,
    PERM_MANAGE_NICKNAMES,
    PERM_MANAGE_ROLES,
    PERM_MANAGE_WEBHOOKS,
    PERM_MANAGE_EMOJIS,
    has_permission,
    mention,
    reply,
    plaintext,
    upload_file,
    set_game

"""
Bitwise permission flags.
More details [here](https://discordapp.com/developers/docs/topics/permissions#permissions-bitwise-permission-flags).
"""
@enum Permission begin
    PERM_CREATE_INSTANT_INVITE=1<<0
    PERM_KICK_MEMBERS=1<<1
    PERM_BAN_MEMBERS=1<<2
    PERM_ADMINISTRATOR=1<<3
    PERM_MANAGE_CHANNELS=1<<4
    PERM_MANAGE_GUILD=1<<5
    PERM_ADD_REACTIONS=1<<6
    PERM_VIEW_AUDIT_LOG=1<<7
    PERM_VIEW_CHANNEL=1<<10
    PERM_SEND_MESSAGES=1<<11
    PERM_SEND_TTS_MESSAGES=1<<12
    PERM_MANAGE_MESSAGES=1<<13
    PERM_EMBED_LINKS=1<<14
    PERM_ATTACH_FILES=1<<15
    PERM_READ_MESSAGE_HISTORY=1<<16
    PERM_MENTION_EVERYONE=1<<17
    PERM_USE_EXTERNAL_EMOJIS=1<<18
    PERM_CONNECT=1<<20
    PERM_SPEAK=1<<21
    PERM_MUTE_MEMBERS=1<<22
    PERM_DEAFEN_MEMBERS=1<<23
    PERM_MOVE_MEMBERS=1<<24
    PERM_USE_VAD=1<<25
    PERM_PRIORITY_SPEAKER=1<<8
    PERM_CHANGE_NICKNAME=1<<26
    PERM_MANAGE_NICKNAMES=1<<27
    PERM_MANAGE_ROLES=1<<28
    PERM_MANAGE_WEBHOOKS=1<<29
    PERM_MANAGE_EMOJIS=1<<30
end

"""
    has_permission(perms::Integer, perm::Permission) -> Bool

Determine whether a bitwise OR of permissions contains one [`Permission`](@ref).

# Example
```jldoctest; setup=:(using Discord)
julia> has_permission(0x0420, PERM_VIEW_CHANNEL)
true

julia> has_permission(0x0420, PERM_ADMINISTRATOR)
false
```
"""
has_permission(perms::Integer, perm::Permission) = perms & Int(perm) == Int(perm)

"""
    mention(x::Union{DiscordChannel, Member, Role, User}) -> String

Get the mention string for an entity.
"""
mention(c::DiscordChannel) = "<#$(c.id)>"
mention(r::Role) = "<@&$(r.id)>"
mention(u::User) = "<@$(u.id)>"
function mention(m::Member)
    return ismissing(m.nick) || m.nick === nothing ? mention(m.user) : "<@!$(m.user.id)>"
end

"""
    reply(
        c::Client,
        m::Message,
        content::Union{AbstractString, AbstractDict, NamedTuple, Embed};
        at::Bool=false,
    ) -> Future{Response}

Reply (send a message to the same [`DiscordChannel`](@ref)) to a [`Message`](@ref).
If `at` is set, then the message is prefixed with the sender's mention.
"""
function reply(c::Client, m::Message, content::AbstractString; at::Bool=false)
    content = at ? mention(m.author) * " " * content : content
    return create_message(c, m.channel_id; content=content)
end

function reply(
    c::Client,
    m::Message,
    embed::Union{AbstractDict, NamedTuple, Embed};
    at::Bool=false,
)
    return if at
        create_message(c, m.channel_id; content=mention(m.author), embed=embed)
    else
        create_message(c, m.channel_id; embed=embed)
    end
end

"""
    plaintext(m::Message) -> String
    plaintext(c::Client, m::Message) -> String

Get the [`Message`](@ref) contents with any [`User`](@ref) mentions replaced with their
plaintext. If a [`Client`](@ref) is provided, [`DiscordChannel`](@ref)s [`Role`](@ref) are
also replaced. However, only channels and roles stored in state are replaced; no API
requests are made.
"""
function plaintext(m::Message)
    content = m.content

    for u in coalesce(m.mentions, User[])
        name = "@$(u.username)"
        content = replace(content, "<@$(u.id)>" => name)
        content = replace(content, "<@!$(u.id)>" => name)
    end

    return content
end

function plaintext(c::Client, m::Message)
    content = m.content

    for u in coalesce(m.mentions, User[])
        member = get(c.state, Member; guild=m.guild_id, user=u.id)
        nick = if member !== nothing && member.nick isa String
            "@$(member.nick)"
        else
            "@$(u.username)"
        end
        content = replace(content, "<@$(u.id)>" => "@$(u.username)")
        content = replace(content, "<@!$(u.id)>" => "@$nick")
    end

    guild = get(c.state, Guild; guild=m.guild_id)
    if guild !== nothing
        for r in coalesce(m.mention_roles, Snowflake[])
            role = get(c.state, Role; guild=m.guild_id, role=r)
            if role !== nothing
                content = replace(content, "<@&$r>" => "@$(role.name)")
            end
        end

        for cap in unique(eachmatch(r"<#(\d+?)>", content))
            ch = get(c.state, DiscordChannel; channel=parse(Snowflake, first(cap.captures)))
            if ch !== nothing
                content = replace(content, cap.match => "#$(ch.name)")
            end
        end
    end

    return content
end

"""
    upload_file(c::Client, ch::DiscordChannel, path::AbstractString; kwargs...) -> Message

Send a [`Message`](@ref) with a file [`Attachment`](@ref). Any keywords are passed on to
[`create_message`](@ref).
"""
function upload_file(c::Client, ch::DiscordChannel, path::AbstractString; kwargs...)
    return create_message(c, ch.id; kwargs..., file=open(path))
end

"""
    set_game(
        c::Client,
        name::AbstractString,
        type::Union{ActivityType, Int}=AT_GAME,
        since::Union{Int, Nothing}=nothing,
        status::Union{PresenceStatus, AbstractString}=PS_ONLINE,
        afk::Bool=false,
        kwargs...,
    ) -> Bool

Shortcut for [`update_status`](@ref) to set the [`Client`](@ref)'s [`Activity`](@ref).
"""
function set_game(
    c::Client,
    game::AbstractString;
    type::Union{ActivityType, Int}=AT_GAME,
    since::Union{Int, Nothing}=nothing,
    status::Union{PresenceStatus, AbstractString}=PS_ONLINE,
    afk::Bool=false,
    kwargs...,
)
    activity = merge(Dict("name" => game, "type" => type), kwargs)
    return update_status(c, since, activity, status, afk)
end
