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
    help::AbstractString
    cooldown::Union{Period, Nothing}
    cooldowns::TTL{Snowflake, Nothing}

    function Command(
        h::Handler{MessageCreate},
        name::Symbol,
        help::AbstractString,
        cooldown::Union{Period, Nothing},
    )
        return new(h, name, help, cooldown, TTL{Snowflake, Nothing}(cooldown))
    end
end

function Command(;
    name::Symbol,
    handler::Function,
    help::AbstractString="",
    parsers::Vector=[],
    separator::Union{AbstractString, AbstractChar}=' ',
    pattern::Regex=defaultpattern(name, length(parsers), separator),
    allowed::Vector{<:Integer}=Snowflake[],
    cooldown::Union{Period, Nothing}=nothing,
    fallback::Function=donothing,
    priority::Int=DEFAULT_PRIORITY,
    n::Union{Int, Nothing}=nothing,
    timeout::Union{Period, Nothing}=nothing,
)
    if !any(methods(handler)) do m
        length(m.sig.types) < 3 && return false
        return Client <: m.sig.types[2] && Message <: m.sig.types[3]
    end
        throw(ArgumentError("Handler function must accept (::Client, ::Message, ...)"))
    end
    if !all(p -> p isa Base.Callable, parsers)
        throw(ArgumentError("All parsers must be callable"))
    end
    if count(p -> p isa Splat, parsers) > 1
        throw(ArgumentError("Only one Splat parser can be used at a time"))
    end

    function wrapped_handler(c::Client, e::MessageCreate)
        ismissing(e.message.webhook_id) || return
        isempty(e.message.content) && return

        pfx = prefix(c, e.message.guild_id)
        startswith(e.message.content, pfx) || return

        id = me(c) === nothing ? nothing : me(c).id
        !ismissing(e.message.author) && e.message.author.id == id && return

        m = match(pattern, noprefix(e.message.content, pfx))
        m === nothing && return

        # None of the above cases result in fallback handlers running.

        caps = try
            parsecaps(parsers, m.captures)
        catch e
            kws = logkws(c; command=name, exception=(e, catch_backtrace()))
            @warn "Parsers threw an exception" kws...
            throw(Fallback())
        end

        if !isempty(allowed)
            ids = ismissing(e.message.author) ? Snowflake[] : [e.message.author.id]
            if ismissing(e.message.member)
                # TODO: Should we be making potential REST calls here?
                # It's very likely that everything is cached but that's not a given.
                if !ismissing(e.message.guild_id)
                    guild = fetch(retrieve(c, Guild, e.message.guild_id))
                    if guild.ok
                        member = fetch(retrieve(c, Member, guild.val, e.message.author))
                        member.ok && append!(ids, member.val.roles)
                    end
                end
            else
                append!(ids, e.message.member.roles)
            end

            # We do run the fallback for lack of permissions.
            any(id -> id in allowed, ids) || throw(Fallback())
        end

        if cooldown !== nothing && !ismissing(e.message.author)
            cmd = get(get(c.handlers, MessageCreate, Dict()), name, nothing)
            if cmd !== nothing && haskey(cmd.cooldowns, e.message.author.id)
                throw(Fallback())
            end
            cmd.cooldowns[e.message.author.id] = nothing
        end

        handler(c, e.message, caps...)
    end

    # Run the fallback on the message itself.
    function wrapped_fallback(c::Client, e::MessageCreate)
        fallback(c, e.message)
    end

    return Command(
        Handler{MessageCreate}(
            alwaystrue, wrapped_handler, wrapped_fallback,
            priority, n, timeout, false,
        ),
        name, help, cooldown,
    )
end

"""
    @command name=name handler=handler kwargs...

Mark a function as a bot command to be collected by [`add_command!`](@ref) (from a module).
Supported keywords are identical to `add_command!`.

# Example
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
    Splat(
        func::Base.Callable=identity,
        split::Union{AbstractString, AbstractChar}=' ',
    ) -> Splat

Collect a variable number of arguments from one capture group with a single parser.
"""
struct Splat <: Function
    func::Base.Callable
    split::Union{AbstractString, AbstractChar}
end
Splat() = Splat(identity, ' ')
Splat(func::Base.Callable) = Splat(func, ' ')
Splat(split::Union{AbstractString, AbstractChar}) = Splat(identity, split)

predicate(c::Command) = predicate(c.h)
handler(c::Command) = handler(c.h)
fallback(c::Command) = fallback(c.h)
priority(c::Command) = priority(c.h)
expiry(c::Command) = expiry(c.h)
dec!(c::Command) = dec!(c.h)
isexpired(c::Command) = isexpired(c.h)

"""
    add_command!(
        c::Client,
        name::Symbol,
        handler::Function;
        help::AbstractString="",
        parsers::Vector=[],
        separator::Union{AbstractString, AbstractChar}=' ',
        pattern::Regex=defaultpattern(name, length(parsers), separator),
        allowed::Vector{<:Integer}=Snowflake[],
        cooldown::Union{Period, Nothing}=nothing,
        fallback::Function=donothing,
        priority::Int=$DEFAULT_PRIORITY,
        n::Union{Int, Nothing}=nothing,
        timeout::Union{Period, Nothing}=nothing,
        compile::Bool=false,
        kwargs...,
    )

Add a text command handler. `do` syntax is also accepted.

# Handler Function
The handler function must accept a [`Client`](@ref) and a [`Message`](@ref). Additionally,
it can accept any number of additional arguments, which are captured from `pattern`
and parsed with `parsers` (see below).

# Command Pattern
The `pattern` keyword specifies how to invoke the command. The given `Regex` must match the
message contents after having removed the command prefix. By default, it's the command name
with as many wildcard capture groups as there are parsers, separated by the `separator`
keyword (a space character by default).

# Command Help
The `help` keyword specifies a help string which can be used by [`add_help!`](@ref).

# Argument Parsing
The `parsers` keyword specifies the parsers of the command arguments, and can contain both
types and functions. If `pattern` contains captures, then they are run through the parsers
before being passed into the handler. For repeating arguments, see [`Splat`](@ref).

# Permissions
The `allowed` keyword specifies [`User`](@ref)s or [`Role`](@ref)s (by ID) that are allowed
to use the command. If the caller does not have permissions for the command, the fallback
handler is run.

# Rate Limiting
The `cooldown` keyword sets the rate at which a user can invoke the command. The default
of `nothing` indicates no limit.

# Fallback Function
The `fallback` keyword specifies a function that runs whenever a command is called but
cannot be run, such as failed argument parsing, missing permissions, or rate limiting.
it should accept a [`Client`](@ref) and a [`Message`](@ref).

Additional keyword arguments are a subset of those to [`add_handler!`](@ref).

# Examples
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
Splatting some comma-separated numbers with a fallback function:
```julia
add_command!(
    c, :sum, (c, m, xs...) -> reply(c, m, string(sum(collect(xs))));
    parsers=[Splat(Float64, ',')], fallback=(c, m) -> reply(c, m, "Args must be numbers."),
)
```
"""
function add_command!(
    c::Client,
    name::Symbol,
    handler::Function;
    help::AbstractString="",
    parsers::Vector=[],
    separator::Union{AbstractString, AbstractChar}=' ',
    pattern::Regex=defaultpattern(name, length(parsers), separator),
    allowed::Vector{<:Integer}=Snowflake[],
    cooldown::Union{Period, Nothing}=nothing,
    fallback::Function=donothing,
    priority::Int=DEFAULT_PRIORITY,
    n::Union{Int, Nothing}=nothing,
    timeout::Union{Period, Nothing}=nothing,
    compile::Bool=false,
    kwargs...,
)
    cmd = Command(;
        name=name, handler=handler, help=help, parsers=parsers, separator=separator,
        pattern=pattern, allowed=allowed, fallback=fallback, cooldown=cooldown,
        priority=priority, n=n, timeout=timeout,
    )
    puthandler!(c, cmd, name, compile; kwargs...)
end

function add_command!(
    handler::Function,
    c::Client,
    name::Symbol;
    help::AbstractString="",
    parsers::Vector=[],
    separator::Union{AbstractString, AbstractChar}=' ',
    pattern::Regex=defaultpattern(name, length(parsers), separator),
    allowed::Vector{<:Integer}=Snowflake[],
    cooldown::Union{Period, Nothing}=nothing,
    fallback::Function=donothing,
    priority::Int=DEFAULT_PRIORITY,
    n::Union{Int, Nothing}=nothing,
    timeout::Union{Period, Nothing}=nothing,
    compile::Bool=false,
    kwargs...
)
    add_command!(
        c, name, handler;
        help=help, separator=separator, parsers=parsers, pattern=pattern, allowed=allowed,
        cooldown=cooldown, priority=priority, fallback=fallback, n=n, timeout=timeout,
        compile=compile, kwargs...,
    )
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

# Keywords
- `separator::Union{AbstractString, AbstractChar}`: Separator between commands.
- `pattern::Regex`: The command pattern (see [`add_command!`](@ref)).
- `help::AbstractString`: Help for the help command.
- `nohelp::AbstractString`: Help for commands without their own help string.
- `nocmd::AbstractString`: Help for commands that aren't found.
"""
function add_help!(
    c::Client;
    separator::Union{AbstractString, AbstractChar}=' ',
    pattern::Regex=r"^help(?: (.+))?",
    help::AbstractString="Show this help message",
    nohelp::AbstractString="No help provided",
    nocmd::AbstractString="Command not found",
)
    function handler(c::Client, m::Message, names::AbstractString...)
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
        compile=true, message=mock(Message; content=prefix(c) * "help"),
    )
end

"""
    set_prefix!(c::Client, prefix::Union{AbstractString, AbstractChar})
    set_prefix!(
        c::Client,
        prefix::Union{AbstractString, AbstractChar},
        guild::Union{Guild, Integer},
    )

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
prefix(c::Client) = c.p_global
prefix(c::Client, ::Missing) = c.p_global
prefix(c::Client, guild::Integer) = get(c.p_guilds, guild, c.p_global)

# Get a string without a prefix.
function noprefix(s::AbstractString, p::AbstractString)
    return startswith(s, p) ? s[nextind(s, 1, length(p)):end] : s
end

# Parse command arguments.
function parsecaps(parsers::Vector, caps::Vector)
    len = min(length(parsers), length(caps))
    parsers = parsers[1:len]
    unparsed = splice!(caps, len+1:lastindex(caps))
    args = Vector{Any}(vcat(map(t -> parsecap(t...), zip(parsers, caps))...))
    return append!(vcat(args...), unparsed)
end

# Parse a single capture.
parsecap(::Base.Callable, ::Nothing) = []  # Optional captures don't return anything.
parsecap(p::Function, s::AbstractString) = Any[p(s)]
parsecap(p::Splat, s::AbstractString) = Any[parsecap.(p.func, split(s, p.split))...]
function parsecap(p::Type, s::AbstractString)
    return Any[hasmethod(parse, (Type{p}, AbstractString)) ? parse(p, s) : p(s)]
end

# Generate a bot command's default pattern.
function defaultpattern(name::Symbol, n::Int, separator::Union{AbstractString, AbstractChar})
    return n == 0 ? Regex("^$name") : Regex("^$name " * join(repeat(["(.*)"], n), separator))
end
