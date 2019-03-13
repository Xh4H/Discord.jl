export Splat,
    add_command!,
    delete_command!,
    add_help!,
    set_prefix!,
    @command

# A bot command handler.
struct Command <: AbstractHandler{MessageCreate}
    h::Handler{MessageCreate}
    name::Symbol
    help::String
    cooldowns::Nullable{TTL{Snowflake, Nothing}}
    fb_parsers::Function
    fb_allowed::Function
    fb_permissions::Function
    fb_cooldown::Function

    function Command(
        h::Handler{MessageCreate},
        name::Symbol,
        help::AbstractString,
        cooldown::Nullable{Period},
        fb_parsers::Function,
        fb_allowed::Function,
        fb_permissions::Function,
        fb_cooldown::Function,
    )
        cds = cooldown === nothing ? nothing : TTL{Snowflake, Nothing}(cooldown)
        return new(h, name, help, cds, fb_parsers, fb_allowed, fb_permissions, fb_cooldown)
    end
end

function Command(;
    name::Symbol,
    handler::Function,
    help::AbstractString="",
    parsers::Vector=[],
    separator::StringOrChar=' ',
    pattern::Regex=defaultpattern(name, length(parsers), separator),
    allowed::Vector{<:Integer}=Snowflake[],
    permissions::Integer=PERM_NONE,
    cooldown::Nullable{Period}=nothing,
    fallback_parsers::Function=donothing,
    fallback_allowed::Function=donothing,
    fallback_permissions::Function=donothing,
    fallback_cooldown::Function=donothing,
    priority::Int=DEFAULT_PRIORITY,
    remaining::Nullable{Int}=nothing,
    timeout::Nullable{Period}=nothing,
)
    fbs = [fallback_parsers, fallback_allowed, fallback_permissions, fallback_cooldown]
    if any(f -> !hasmethod(f, (Client, Message)), fbs)
        throw(ArgumentError("Fallback handlers must accept (::Client, Message)"))
    elseif !any(methods(handler)) do m
        length(m.sig.types) < 3 && return false
        return Client <: m.sig.types[2] && Message <: m.sig.types[3]
    end
        throw(ArgumentError("Handler function must accept (::Client, ::Message, ...)"))
    elseif !all(p -> p isa Base.Callable, parsers)
        throw(ArgumentError("All parsers must be callable"))
    elseif count(p -> p isa Splat, parsers) > 1
        throw(ArgumentError("Only one Splat parser can be used at a time"))
    end

    function predicate(c::Client, e::MessageCreate)
        # Exclude webhooks and empty messages.
        ismissing(e.message.webhook_id) || return false
        isempty(e.message.content) && return false

        # Exclude self messages.
        id = me(c) === nothing ? nothing : me(c).id
        author = e.message.author
        !ismissing(author) && author.id == id && return false

        # Check the prefix.
        pfx = prefix(c, e.message.guild_id)
        startswith(e.message.content, pfx) || return false

        # Check the pattern.
        m = match(pattern, noprefix(e.message.content, pfx))
        m === nothing && return false

        # Check the arguments.
        try
            parsecaps(parsers, Any[m.captures...])
        catch
            return FB_PARSERS
        end

        # Check authorization.
        if !isempty(allowed)
            ids = ismissing(author) ? Snowflake[] : [author.id]
            if ismissing(e.message.member)
                # TODO: Should we be making potential REST calls here (also in perm check)?
                # It's very likely that everything is cached but that's not a given.
                if !ismissing(e.message.guild_id)
                    guild = fetch(retrieve(c, Guild, e.message.guild_id))
                    if guild.ok
                        member = fetch(retrieve(c, Member, guild.val, author))
                        member.ok && append!(ids, member.val.roles)
                    end
                end
            else
                append!(ids, e.message.member.roles)
            end

            # We do run the fallback for lack of permissions.
            any(id -> id in allowed, ids) || return FB_ALLOWED
        end

        # Check permissions.
        if !ismissing(author) && !ismissing(e.message.guild_id) && permissions != PERM_NONE
            @deferred_fetch begin
                guild = retrieve(c, Guild, e.message.guild_id)
                channel = retrieve(c, DiscordChannel, e.message.channel_id)
            end
            if guild.ok && channel.ok
                member = fetch(retrieve(c, guild.val, author))
                if member.ok
                    user_perms = permissions_in(member.val, guild.val, channel.val)
                    user_perms & permissions == permissions || return FB_PERMISSIONS
                end
            end
        end

        # Check cooldowns.
        if !ismissing(author) && cooldown !== nothing
            cmd = get(get(c.handlers, MessageCreate, Dict()), name, nothing)
            cmd !== nothing && haskey(cmd.cooldowns, author.id) && return FB_COOLDOWN
            cmd.cooldowns[author.id] = nothing  # Update the rate limiter.
        end

        return true
    end

    function wrapped_handler(c::Client, e::MessageCreate)
        m = match(pattern, noprefix(e.message.content, prefix(c, e.message.guild_id)))
        handler(c, e.message, parsecaps(parsers, Any[m.captures...])...)
    end

    # Run the fallbacks on the message itself.
    wrapped_fb_parsers(c::Client, e::MessageCreate) = fallback_parsers(c, e.message)
    wrapped_fb_allowed(c::Client, e::MessageCreate) = fallback_allowed(c, e.message)
    wrapped_fb_permissions(c::Client, e::MessageCreate) = fallback_permissions(c, e.message)
    wrapped_fb_cooldown(c::Client, e::MessageCreate) = fallback_cooldown(c, e.message)

    return Command(
        Handler{MessageCreate}(
            predicate, wrapped_handler, donothing,
            priority, remaining, timeout, nothing, false,
        ),
        name, help, cooldown, wrapped_fb_parsers, wrapped_fb_allowed,
        wrapped_fb_permissions, wrapped_fb_cooldown,
    )
end

"""
    @command name=name handler=handler kwargs...

Mark a function as a bot command to be collected by [`add_command!`](@ref) (from a module).
Supported keywords are identical to `add_command!`.

## Example
```julia
module Commands
using Discord
echo(c::Client, m::Message, noprefix::AbstractString) = reply(c, m, noprefix)
@command name=:echo handler=echo help="Echo a message" pattern=r"^echo (.+)"
end
c = Client("token")
add_command!(c, Commands)
```
"""
macro command(exs...)
    kws = map(ex -> Expr(:kw, ex.args[1], esc(ex.args[2])), exs)
    quote
        $(gensym(:djl_cmd)) = Discord.Command(; $(kws...))
    end
end

"""
    Splat(func::Base.Callable=identity, split::StringOrChar=' ') -> Splat

Collect a variable number of arguments from one capture group with a single parser.
"""
struct Splat <: Function
    func::Base.Callable
    split::StringOrChar
end
Splat() = Splat(identity, ' ')
Splat(func::Base.Callable) = Splat(func, ' ')
Splat(split::StringOrChar) = Splat(identity, split)

predicate(c::Command) = predicate(c.h)
handler(c::Command) = handler(c.h)
priority(c::Command) = priority(c.h)
expiry(c::Command) = expiry(c.h)
dec!(c::Command) = dec!(c.h)
isexpired(c::Command) = isexpired(c.h)
function fallback(c::Command, r::FallbackReason)
    return if r === FB_PARSERS
        c.fb_parsers
    elseif r === FB_ALLOWED
        c.fb_allowed
    elseif r === FB_PERMISSIONS
        c.fb_permissions
    elseif r === FB_COOLDOWN
        c.fb_cooldown
    else
        donothing
    end
end

"""
    add_command!(
        c::Client,
        name::Symbol,
        handler::Function;
        help::AbstractString="",
        parsers::Vector=[],
        separator::StringOrChar=' ',
        pattern::Regex=defaultpattern(name, length(parsers), separator),
        allowed::Vector{<:Integer}=Snowflake[],
        permissions::Integer=PERM_NONE,
        cooldown::Nullable{Period}=nothing,
        fallback_parsers::Function=donothing,
        fallback_allowed::Function=donothing,
        fallback_permissions::Function=donothing,
        fallback_cooldown::Function=donothing,
        priority::Int=$DEFAULT_PRIORITY,
        count::Nullable{Int}=nothing,
        timeout::Nullable{Period}=nothing,
        compile::Bool=false,
        kwargs...,
    )

Add a text command handler. `do` syntax is also accepted.

### Handler Function
The handler function must accept a [`Client`](@ref) and a [`Message`](@ref). Additionally,
it can accept any number of additional arguments, which are captured from `pattern`
and parsed with `parsers` (see below).

### Command Pattern
The `pattern` keyword specifies how to invoke the command. The given `Regex` must match the
message contents after having removed the command prefix. By default, it's the command name
with as many wildcard capture groups as there are parsers, separated by the `separator`
keyword (a space character by default).

### Command Help
The `help` keyword specifies a help string which can be used by [`add_help!`](@ref).

### Argument Parsing
The `parsers` keyword sets the parsers of the command arguments, and can contain both
types and functions. If `pattern` contains captures, then they are run through the parsers
before being passed into the handler. For repeating arguments, see [`Splat`](@ref).

### Authorization + Required Permissions
The `allowed` keyword specifies [`User`](@ref)s or [`Role`](@ref)s (by ID) that are allowed
to use the command. The `permissions` keyword sets the minimum permissions that command
callers must have.

### Rate Limiting
The `cooldown` keyword sets the rate at which a user can invoke the command. The default
of `nothing` indicates no limit.

### Fallback Functions
The `fallback_*` keywords specify functions to be run whenever a command is called but
cannot be run, such as failed argument parsing, missing permissions, or rate limiting.
They should accept a [`Client`](@ref) and a [`Message`](@ref).

Additional keyword arguments are a subset of those to [`add_handler!`](@ref).

## Examples
Basic echo command with a help string:
```julia
add_command!(c, :echo, (c, m) -> reply(c, m, m.content); help="repeat a message")
```
The same, but excluding the command part:
```julia
add_command!(c, :echo, (c, m, msg) -> reply(c, m, msg); pattern=r"^echo (.+)")
```
Parsing a subtraction expression with custom parsers and separator:
```julia
add_command!(
    c, :sub, (c, m, a, b) -> reply(c, m, string(a - b));
    parsers=[Float64, Float64], separator='-',
)
```
Splatting some comma-separated numbers with a parsing fallback function:
```julia
add_command!(
    c, :sum, (c, m, xs...) -> reply(c, m, string(sum(collect(xs))));
    parsers=[Splat(Float64, ',')],
    fallback_parsers=(c, m) -> reply(c, m, "Args must be numbers."),
)
```
"""
function add_command!(
    c::Client,
    name::Symbol,
    handler::Function;
    help::AbstractString="",
    parsers::Vector=[],
    separator::StringOrChar=' ',
    pattern::Regex=defaultpattern(name, length(parsers), separator),
    allowed::Vector{<:Integer}=Snowflake[],
    permissions::Integer=PERM_NONE,
    cooldown::Nullable{Period}=nothing,
    fallback_parsers::Function=donothing,
    fallback_allowed::Function=donothing,
    fallback_permissions::Function=donothing,
    fallback_cooldown::Function=donothing,
    priority::Int=DEFAULT_PRIORITY,
    count::Nullable{Int}=nothing,
    timeout::Nullable{Period}=nothing,
    compile::Bool=false,
    kwargs...,
)
    cmd = Command(;
        name=name, handler=handler, help=help, parsers=parsers, separator=separator,
        pattern=pattern, allowed=allowed, permissions=permissions,
        fallback_parsers=fallback_parsers, cooldown=cooldown, priority=priority,
        remaining=count, timeout=timeout,
    )
    puthandler!(c, cmd, name, compile; message=mock(Message; kwargs...))
end
function add_command!(handler::Function, c::Client, name::Symbol; kwargs...)
    add_command!(c, name, handler; kwargs...)
end

"""
    add_command!(c::Client, m::Module; compile::Bool=false; kwargs...)

Add all of the bot commands defined in a module. To set up commands to be included, see
[`@command`](@ref).
"""
function add_command!(c::Client, m::Module; compile::Bool=false, kwargs...)
    for cmd in filter(cmd -> cmd isa Command, map(n -> getfield(m, n), names(m; all=true)))
        puthandler!(c, cmd, cmd.name, compile; kwargs...)
    end
end

"""
    delete_command!(c::Client, name::Symbol)

Delete a command.
"""
delete_command!(c::Client, name::Symbol) = delete_handler!(c, MessageCreate, name)

"""
    add_help!(
        c::Client;
        pattern::Regex=r"^help(?: (.+))?",
        help::AbstractString="Show this help message",
        nohelp::AbstractString="No help provided",
        nocmd::AbstractString="Command not found",
    )

Add a help command. This can be called at any time, new commands will be included
automatically.

## Keywords
- `separator::StringOrChar`: Separator between commands.
- `pattern::Regex`: The command pattern (see [`add_command!`](@ref)).
- `help::AbstractString`: Help for the help command.
- `nohelp::AbstractString`: Help for commands without their own help string.
- `nocmd::AbstractString`: Help for commands that aren't found.
"""
function add_help!(
    c::Client;
    separator::StringOrChar=' ',
    pattern::Regex=r"^help(?: (.+))?",
    help::AbstractString="Show this help message",
    nohelp::AbstractString="No help provided",
    nocmd::AbstractString="Command not found",
)
    function handler(c::Client, m::Message, names::String...)
        names = strip.(names)
        sort!(collect(names))
        len = maximum(length, names)
        handlers = get(c.handlers, MessageCreate, Dict())
        io = IOBuffer()

        for name in names
            padded = lpad(name, len)
            h = get(handlers, Symbol(name), nothing)
            if h isa Command
                println(io, padded, ": ", isempty(h.help) ? nohelp : h.help)
            else
                println(io, padded, ": ", nocmd)
            end
        end

        reply(c, m, "```\n" * String(take!(io)) * "```")
    end

    function handler(c::Client, m::Message, ::Nothing=nothing)
        cmds = collect(get(c.handlers, MessageCreate, Dict()))
        filter!(p -> p.second isa Command, cmds)
        handler(c, m, map(p -> string(p.second.name), cmds)...)
    end

    add_command!(
        c, :help, handler;
        parsers=[Splat(separator)], pattern=pattern, help=help, priority=typemax(Int),
        compile=true, content=prefix(c) * "help",
    )
end

"""
    set_prefix!(c::Client, prefix::StringOrChar)
    set_prefix!(c::Client, prefix::StringOrChar, guild::Union{Guild, Integer})

Set [`Client`](@ref)'s command prefix. If a [`Guild`](@ref) or its ID is supplied, then the
prefix only applies to that guild.
"""
set_prefix!(c::Client, prefix::AbstractString) = c.p_global = prefix
set_prefix!(c::Client, prefix::AbstractString, guild::Integer) = c.p_guilds[guild] = prefix
set_prefix!(c::Client, prefix::AbstractString, g::Guild) = set_prefix!(c, prefix, g.id)
set_prefix!(c::Client, prefix::AbstractChar) = set_prefix!(c, string(prefix))
function set_prefix!(c::Client, prefix::AbstractChar, guild::Union{Guild, Integer})
    set_prefix!(c, string(prefix, guild))
end

# Get the command prefix.
prefix(c::Client, ::Missing=missing) = c.p_global
prefix(c::Client, guild::Integer) = get(c.p_guilds, guild, c.p_global)

# Get a string without a prefix.
function noprefix(s::AbstractString, p::AbstractString)
    return startswith(s, p) ? s[nextind(s, 1, length(p)):end] : s
end

# Parse command arguments.
function parsecaps(parsers::Vector, caps::Vector)
    map!(c -> c isa AbstractString ? string(c) : c, caps, caps)
    len = min(length(parsers), length(caps))
    parsers = parsers[1:len]
    unparsed = splice!(caps, len+1:lastindex(caps))
    args = Any[vcat(map(t -> parsecap(t...), zip(parsers, caps))...)...]
    return append!(vcat(args...), unparsed)
end

# Parse a single capture.
parsecap(::Base.Callable, ::Nothing) = []  # Optional captures don't return anything.
parsecap(p::Function, s::AbstractString) = Any[p(s)]
parsecap(p::Splat, s::AbstractString) = Any[parsecap.(p.func, string.(split(s, p.split)))...]
function parsecap(p::Type, s::AbstractString)
    return Any[hasmethod(parse, (Type{p}, AbstractString)) ? parse(p, s) : p(s)]
end

# Generate a bot command's default pattern.
function defaultpattern(name::Symbol, n::Int, separator::StringOrChar)
    return n == 0 ? Regex("^$name") : Regex("^$name " * join(repeat(["(.*)"], n), separator))
end
