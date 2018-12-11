export PERM_ALL,
    has_permission,
    permissions_in,
    reply,
    split_message,
    plaintext,
    heartbeat_ping,
    upload_file,
    set_game,
    @fetch,
    @fetchval,
    @deferred_fetch,
    @deferred_fetchval

const CRUD_FNS = :create, :retrieve, :update, :delete

const STYLES = [
    r"```.+?```"s, r"`.+?`", r"~~.+?~~", r"_.+?_", r"__.+?__",
    r"\*.+?\*", r"\*\*.+?\*\*", r"\*\*\*.+?\*\*\*",
]

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
@boilerplate Permission :export

const PERM_ALL = |(Int.(instances(Permission))...)

"""
    has_permission(perms::Integer, perm::Permission) -> Bool

Determine whether a bitwise OR of permissions contains one [`Permission`](@ref).

## Example
```jldoctest; setup=:(using Discord)
julia> has_permission(0x0420, PERM_VIEW_CHANNEL)
true

julia> has_permission(0x0420, PERM_ADMINISTRATOR)
false

julia> has_permission(0x0008, PERM_MANAGE_ROLES)
true
```
"""
function has_permission(perms::Integer, perm::Permission)
    admin = perms & Int(PERM_ADMINISTRATOR) == Int(PERM_ADMINISTRATOR)
    has = perms & Int(perm) == Int(perm)
    return admin || has
end

"""
    permissions_in(m::Member, g::Guild, ch::DiscordChannel) -> Int

Compute a [`Member`](@ref)'s [`Permission`](@ref)s in a [`DiscordChannel`](@ref).
"""
function permissions_in(m::Member, g::Guild, ch::DiscordChannel)
    !ismissing(m.user) && m.user.id == g.owner_id && return PERM_ALL

    # Get permissions for @everyone.
    idx = findfirst(r -> r.name == "@everyone", g.roles)
    everyone = idx === nothing ? nothing : g.roles[idx]
    perms = idx === nothing ? 0 : everyone.permissions
    perms & Int(PERM_ADMINISTRATOR) == Int(PERM_ADMINISTRATOR) && return PERM_ALL

    # Apply role overwrites.
    for role in [everyone.id; m.roles]
        idx = findfirst(
            o -> o.type === OT_ROLE && o.id == role,
            coalesce(ch.permission_overwrites, Overwrite[]),
        )
        if idx !== nothing
            o = ch.permission_overwrites[idx]
            perms &= ~o.deny
            perms |= o.allow
        end
    end

    # Apply user-specific overwrite.
    if !ismissing(m.user)
        idx = findfirst(
            o -> o.type === OT_MEMBER && o.id == m.user.id,
            coalesce(ch.permission_overwrites, Overwrite[]),
        )
        if idx !== nothing
            o = ch.permission_overwrites[idx]
            perms &= ~o.deny
            perms |= o.allow
        end
    end

    return perms
end

Base.show(io::IO, c::DiscordChannel) = print(io,"<#$(c.id)>")
Base.show(io::IO, r::Role) = print(io, "<@&$(r.id)>")
Base.show(io::IO, u::User) = print(io, "<@$(u.id)>")
function Base.show(io::IO, m::Member)
    if ismissing(m.nick) || m.nick === nothing
        show(io, m.user)
    else
        print(io, "<@!$(m.user.id)>")
    end
end
function Base.show(io::IO, e::Emoji)
    print(io, e.id === nothing ? ":$(e.name):" : "<:$(e.name):$(e.id)>")
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
    at && !ismissing(m.author) && (content = string(m.author) * " " * content)
    return create_message(c, m.channel_id; content=content)
end

function reply(
    c::Client,
    m::Message,
    embed::Union{AbstractDict, NamedTuple, Embed};
    at::Bool=false,
)
    return if at && !ismissing(m.author)
        create_message(c, m.channel_id; content=string(m.author), embed=embed)
    else
        create_message(c, m.channel_id; embed=embed)
    end
end

"""
    split_message(text::AbstractString) -> Vector{String}

Split a message into 2000-character chunks, preserving formatting.

## Examples
```jldoctest; setup=:(using Discord)
julia> split_message("foo")
1-element Array{String,1}:
 "foo"

julia> split_message(repeat('.', 1995) * "**hello, world**")[2]
"**hello, world**"
"""
function split_message(text::AbstractString)
    length(text) <= 2000 && return String[text]
    chunks = String[]
    start = 1
    len = length(text)

    # TODO: The indexing here can break with Unicode.
    # TODO: This doesn't work properly for nested formatting, e.g. **foo __bar__ baz**.

    while !isempty(text)
        local stop = 2000

        for m in vcat(collect.(eachmatch.(STYLES, text))...)
            m.offset > 1 && text[m.offset - 1] == '\\' && continue  # Escaped formatting.
            if m.offset + length(m.match) > 2000
                # TODO: Backtrack for a valid index (< 2000).
                stop = m.offset - 1
                break
            end
        end

        # The 2000 boundary hacks around the above TODO but can break formatting.
        stop = min(stop, length(text), 2000)
        stop < length(text) && (stop = something(findlast(isspace, text[1:stop]), stop))
        push!(chunks, strip(text[1:stop]))
        text = text[stop+1:end]
    end

    return chunks
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
    heartbeat_ping(c::Client) -> Union{Period, Nothing}

Get the [`Client`](@ref)'s ping time to the gateway. If the client is not connected, or no
heartbeats have been sent/acknowledged, `nothing` is returned.
"""
function heartbeat_ping(c::Client)
    isopen(c) || return nothing
    zero = DateTime(0)
    return c.last_hb == zero || c.last_ack == zero ? nothing : c.last_ack - c.last_hb
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
        game::AbstractString;
        type::Union{ActivityType, Int}=AT_GAME,
        since::Union{Int, Nothing}=c.presence["since"],
        status::Union{PresenceStatus, AbstractString}=c.presence["status"],
        afk::Bool=c.presence["afk"],
        kwargs...,
    ) -> Bool

Shortcut for [`update_status`](@ref) to set the [`Client`](@ref)'s [`Activity`](@ref). Any
additional keywords are passed into the `activity` section.
"""
function set_game(
    c::Client,
    game::AbstractString;
    type::Union{ActivityType, Int}=AT_GAME,
    since::Union{Int, Nothing}=c.presence["since"],
    status::Union{PresenceStatus, AbstractString}=c.presence["status"],
    afk::Bool=c.presence["afk"],
    kwargs...,
)
    activity = merge(Dict("name" => game, "type" => type), kwargs)
    return update_status(c, since, activity, status, afk)
end

"""
    @fetch [functions...] block

Wrap all calls to the specified CRUD functions ([`create`](@ref), [`retrieve`](@ref),
[`update`](@ref), and [`delete`](@ref)) with `fetch` inside a block. If no functions are
specified, all CRUD functions are wrapped.

## Examples
Wrapping all CRUD functions:
```julia
@fetch begin
    guild_resp = create(c, Guild; name="foo")
    guild_resp.ok || error("Request for new guild failed")
    channel_resp = retrieve(c, DiscordChannel, guild_resp.val)
end
```
Wrapping only calls to `retrieve`:
```julia
@fetch retrieve begin
    resp = retrieve(c, DiscordChannel, 123)
    future = create(c, Message, resp.val; content="foo")  # Behaves normally.
end
```
"""
macro fetch(exs...)
    validate_fetch(exs...)
    fns = length(exs) == 1 ? CRUD_FNS : exs[1:end-1]
    ex = wrapfn!(exs[end], fns, :fetch)
    quote
        $ex
    end
end

"""
    @fetchval [functions...] block

Identical to [`@fetch`](@ref), but calls are wrapped with [`fetchval`](@ref) instead.
"""
macro fetchval(exs...)
    validate_fetch(exs...)
    fns = length(exs) == 1 ? CRUD_FNS : exs[1:end-1]
    ex = wrapfn!(exs[end], fns, :fetchval)
    quote
        $ex
    end
end

"""
    @deferred_fetch [functions...] block

Identical to [`@fetch`](@ref), but `Future`s are not `fetch`ed until the **end** of the
block. This is more efficient, but only works when there are no data dependencies in the
block.

## Examples
This will work:
```julia
@deferred_fetch begin
    guild_resp = create(c, Guild; name="foo")
    channel_resp = retrieve(c, DiscordChannel, 123)
end
```
This will not, because the second call is dependent on the first value:
```julia
@deferred_fetch begin
    guild_resp = create(c, Guild; name="foo")
    channels_resp = retrieve(c, DiscordChannel, guild_resp.val)
end
```
"""
macro deferred_fetch(exs...)
    validate_fetch(exs...)
    fns = length(exs) == 1 ? CRUD_FNS : exs[1:end-1]
    ex = deferfn!(exs[end], fns, :fetch)
    quote
        $ex
    end
end

"""
    @deferred_fetchval [functions...] block

Identical to [`@deferred_fetch`](@ref), but `Future`s have [`fetchval`](@ref) called on
them instead of `fetch`.
"""
macro deferred_fetchval(exs...)
    validate_fetch(exs...)
    fns = length(exs) == 1 ? CRUD_FNS : exs[1:end-1]
    ex = deferfn!(exs[end], fns, :fetchval)
    quote
        $ex
    end
end

# Validate the arguments to CRUD macros.
function validate_fetch(exs...)
    if !(exs[end] isa Expr && exs[end].head === :block)
        throw(ArgumentError("Final argument must be a block"))
    end
    if !all(fn -> fn in CRUD_FNS, exs[1:end-1])
        throw(ArgumentError("Only CRUD functions can be wrapped"))
    end
end

# Wrap calls to certain functions in a call to another function.
wrapfn!(ex, ::Tuple, ::Symbol) = esc(ex)
function wrapfn!(ex::Expr, fns::Tuple, with::Symbol)
    if ex.head === :call && ex.args[1] in fns
        ex = :($(esc(with))($(esc(ex))))
    else
        map!(arg -> wrapfn!(arg, fns, with), ex.args, ex.args)
    end
    return ex
end

# Defer fetching a Future until the end of a block.
deferfn!(ex, ::Tuple) = (esc(ex), Pair{Symbol, Symbol}[])
function deferfn!(ex::Expr, fns::Tuple)
    renames = Pair{Symbol, Symbol}[]

    if ex.head === :(=) && ex.args[2] isa  Expr && ex.args[2].args[1] in fns
        newsym = gensym(ex.args[1])
        push!(renames, ex.args[1] =>  newsym)
        ex.args[1] = newsym
        map!(esc, ex.args, ex.args)
    else
        for i in eachindex(ex.args)
            ex.args[i], rs = deferfn!(ex.args[i], fns)
            append!(renames, rs)
        end
    end

    return ex, renames
end
function deferfn!(ex, fns::Tuple, deferred::Symbol)
    ex, renames = deferfn!(ex, fns)
    repls = map(r -> :($(esc(r[1])) = $(esc(deferred))($(esc(r[2])))), renames)
    append!(ex.args, repls)
    return ex
end
