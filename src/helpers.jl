export reply,
    mention,
    plaintext,
    upload_file,
    set_game

"""
    reply(c::Client, m::Message, content::AbstractString; at::Bool=false)

Reply (send a message to the same [`DiscordChannel`](@ref)) to a [`Message`](@ref).
If `at` is set, then the message is prefixed with the sender's mention.
"""
function reply(c::Client, m::Message, content::AbstractString; at::Bool=false)
    content = at ? mention(m.author) * " " * content : content
    return create_message(c, m.channel_id; content=content)
end

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
    plaintext(m::Message) -> String
    plaintext(c::Client, m::Message) -> String

Get the [`Message`](@ref) contents with any [`User`](@ref) mentions replaced with their
plaintext. If a [`Client`](@ref) is provided, channels and roles are also replaced.
However, only channels and roles stored in state are replaced; no API requests are made.
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
    upload_file(c::Client, ch::DiscordChanne, path::AbstractString; kwargs...) -> Message

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

Shortcut for [`update_status`](@ref) to set the client's [`Activity`](@ref).
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
