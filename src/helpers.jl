export reply,
    mention,
    replace_mentions,
    upload_file

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
    replace_mentions(m::Message) -> String

Get the [`Message`](@ref) contents with any [`User`](@ref) mentions replaced with their
plaintext.
"""
function replace_mentions(m::Message)
    ismissing(m.mentions) && return m.content
    content = m.content
    for u in m.mentions
        name = "@$(u.username)"
        content = replace(content, "<@$(u.id)>" => name)
        content = replace(content, "<@!$(u.id)>" => name)
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
