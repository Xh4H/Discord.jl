export PERM_NONE,
    PERM_ALL,
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

"""
Regex expressions for [`split_message`](@ref) to not break Discord formatting.
"""
const STYLES = [
    r"```.+?```"s, r"`.+?`", r"~~.+?~~", r"(_|__).+?\1", r"(\*+).+?\1",
]

"""
Bitwise permission flags.
More details [here](https://discordapp.com/developers/docs/topics/permissions#permissions-bitwise-permission-flags).
"""
@enum Permission::Int64 begin
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
    PERM_STREAM=1<<9
    PERM_CHANGE_NICKNAME=1<<26
    PERM_MANAGE_NICKNAMES=1<<27
    PERM_MANAGE_ROLES=1<<28
    PERM_MANAGE_WEBHOOKS=1<<29
    PERM_MANAGE_EMOJIS=1<<30
    PERM_USE_APPLICATION_COMMANDS=1<<31
    PERM_REQUEST_TO_SPEAK=1<<32
    PERM_MANAGE_EVENTS=1<<33
    PERM_MANAGE_THREADS=1<<34
    PERM_CREATE_PUBLIC_THREADS=1<<35
    PERM_CREATE_PRIVATE_THREADS=1<<36
    PERM_USE_EXTERNAL_STICKERS=1<<37
    PERM_SEND_MESSAGES_IN_THREADS=1<<38
    PERM_START_EMBEDDED_ACTIVITIES=1<<39
    PERM_MODERATE_MEMBERS=1<<40
end
@boilerplate Permission :export

const PERM_NONE = 0
const PERM_ALL = |(Int.(instances(Permission))...)

"""
    has_permission(perms::Integer, perm::Permission) -> Bool

Determine whether a bitwise OR of permissions contains one [`Permission`](@ref).

## Examples
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
    admin = perms & Int64(PERM_ADMINISTRATOR) == Int64(PERM_ADMINISTRATOR)
    has = perms & Int64(perm) == Int64(perm)
    return admin || has
end

"""
    permissions_in(m::Member, g::Guild, ch::DiscordChannel) -> Int64

Compute a [`Member`](@ref)'s [`Permission`](@ref)s in a [`DiscordChannel`](@ref).
"""
function permissions_in(m::Member, g::Guild, ch::DiscordChannel)
    !ismissing(m.user) && m.user.id == g.owner_id && return PERM_ALL

    # Get permissions for @everyone.
    idx = findfirst(r -> r.name == "@everyone", g.roles)
    everyone = idx === nothing ? nothing : g.roles[idx]
    perms = idx === nothing ? Int64(0) : everyone.permissions
    perms & Int64(PERM_ADMINISTRATOR) == Int64(PERM_ADMINISTRATOR) && return PERM_ALL

    roles = idx === nothing ? m.roles : [everyone.id; m.roles]

    # Apply role overwrites.
    for role in roles
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

Base.print(io::IO, c::DiscordChannel) = print(io, "<#$(c.id)>")
Base.print(io::IO, r::Role) = print(io, "<@&$(r.id)>")
Base.print(io::IO, u::User) = print(io, "<@$(u.id)>")
function Base.print(io::IO, m::Member)
    if ismissing(m.user)
        print(io, something(coalesce(m.nick, "<unknown member>"), "<unknown member>"))
    elseif ismissing(m.nick) || m.nick === nothing
        print(io, m.user)
    else
        print(io, "<@!$(m.user.id)>")
    end
end
function Base.print(io::IO, e::Emoji)
    s = if e.id === nothing
        coalesce(e.require_colons, false) ? ":$(e.name):" : e.name
    else
        coalesce(e.animated, false) ? "<a:$(e.name):$(e.id)>" : "<:$(e.name):$(e.id)>"
    end
    print(io, s)
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
    at && !ismissing(m.author) && (content = string(m.author, " ", content))
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
    filter_ranges(u::Vector{UnitRange{Int}})

Filter a list of ranges, discarding ranges included in other ranges from the list.

# Example
```jldoctest; setup=:(using Discord)
julia> Discord.filter_ranges([1:5, 3:8, 1:20, 2:16, 10:70, 25:60, 5:35, 50:90, 10:70])
4-element Vector{UnitRange{Int64}}:
 1:20
 5:35
 50:90
 10:70
```
"""
function filter_ranges(u::Vector{UnitRange{Int}})
    v = fill(true, length(u))
    for i in 1:length(u)
        if !all(m -> (m[1] == i) || (u[i] ⊈ m[2]),
                m for m in enumerate(u) if v[m[1]] == true)
            v[i] = false
        end
    end
    return u[v]
end


"""
    split_message(text::AbstractString; chunk_limit::UInt=2000,
                  extrastyles::Vector{Regex}=Vector{Regex}(),
                  forcesplit::Bool = true) -> Vector{String}

Split a message into chunks with at most chunk_limit length, preserving formatting.

The `chunk_limit` has as default the 2000 character limit of Discord's messages,
but can be changed to any nonnegative integer.

Formatting is specified by [`STYLES`](@ref)) and can be aggregated
with the `extrastyles` argument.

Discord limits messages to 2000, so the code forces split if format breaking
cannot be avoided. If desired, however, this behavior can be lifter by setting
`forcesplit` to false.

## Examples
```jldoctest; setup=:(using Discord)
julia> split_message("foo")
1-element Vector{String}:
 "foo"

julia> split_message(repeat('.', 1995) * "**hello, world**")[2]
"**hello, world**"

julia> split_message("**hello**, *world*", chunk_limit=10)
2-element Vector{String}:
 "**hello**,"
 "*world*"

julia> split_message("**hello**, _*beautiful* world_", chunk_limit=15)
┌ Warning: message was forced-split to fit the desired chunk length limit 15
└ @ Main REPL[66]:28
3-element Vector{String}:
 "**hello**,"
 "_*beautiful* wo"
 "rld_"

julia> split_message("**hello**, _*beautiful* world_", chunk_limit=15, forcesplit=false)
┌ Warning: message could not be split into chunks smaller than the length limit 15
└ @ Main REPL[66]:32
2-element Vector{String}:
 "**hello**,"
 "_*beautiful* world_"

julia> split_message("**hello**\n=====\n", 12)
2-element Vector{String}:
 "**hello**\n=="
 "==="

julia> split_message("**hello**\n≡≡≡≡≡\n", chunk_limit=12, extrastyles = [r"\n≡+\n"])
2-element Vector{String}:
 "**hello**"
 "≡≡≡≡≡"
"""
function split_message(text::AbstractString; chunk_limit::Int=2000,
                       extrastyles::Vector{Regex}=Vector{Regex}(),
                       forcesplit::Bool = true)
    chunks = String[]
    text = strip(text)

    while !isempty(text)
        if length(text) ≤ chunk_limit
            push!(chunks, strip(text))
            return chunks
        end
        # get ranges associated with the formattings
        # mranges = vcat(findall.(union(STYLES, extrastyles),Ref(text))...) can't use findall in julia 1.0 and 1.1 ...
        mranges = [m.offset:m.offset+ncodeunits(m.match)-1 for m in vcat(collect.(eachmatch.(union(STYLES, extrastyles), text))...)]
        # filter ranges to eliminate inner formattings
        franges = filter_ranges(mranges)
        # get ranges that get split apart by the chunk limit - there should be only one, unless text is ill-formatted
        splitranges = filter(r -> (length(text[1:r[1]]) ≤ chunk_limit) & (length(text[1:r[end]]) > chunk_limit), franges)

        if length(splitranges) > 0
            stop = minimum(map(r -> prevind(text, r[1]), splitranges))
        end

        if length(splitranges) == 0
            # get highest valid unicode index if no range is split apart
            stop = maximum(filter(n -> length(text[1:n])≤chunk_limit, thisind.(Ref(text), 1:ncodeunits(text))))
        elseif (stop == 0) && (forcesplit == true)
            # get highest valid unicode if format breaking cannot be avoided and forcesplit is true
            stop = maximum(filter(n -> length(text[1:n])≤chunk_limit, thisind.(Ref(text), 1:ncodeunits(text))))
            # @warn "message was forced-split to fit the desired chunk length limit $chunk_limit"
        elseif stop == 0
            # give up at this point if current chunk cannot be split and `forcesplit` is set to false
            push!(chunks, strip(text))
            # @warn "message could not be split into chunks smaller than the length limit $chunk_limit"
            return chunks
        end

        # splits preferably at a space-like character
        lastspace = findlast(isspace, text[1:stop])
        if lastspace !== nothing
            stop = lastspace
        end

        # push chunk and select remaining text
        push!(chunks, strip(text[1:stop]))
        text = strip(text[nextind(text, stop):end])
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
    heartbeat_ping(c::Client) -> Nullable{Period}

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
        since::Nullable{Int}=c.presence["since"],
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
    since::Nullable{Int}=c.presence["since"],
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
