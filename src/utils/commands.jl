export Splat,
    add_command!,
    delete_command!,
    add_help!,
    set_prefix!

struct Command <: AbstractHandler{MessageCreate}
    h::Handler{MessageCreate}
    name::Symbol
    help::AbstractString
end

"""
    Splat(
        f::Base.Callable=identity,
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

func(c::Command) = func(c.h)
pred(c::Command) = pred(c.h)
expiry(c::Command) = expiry(c.h)
dec!(c::Command) = dec!(c.h)
isexpired(c::Command) = isexpired(c.h)

"""
    add_command!(
        c::Client,
        name::Symbol,
        func::Function;
        pattern::Regex=Regex("^\$name"),
        help::AbstractString="",
        parsers::Vector=[],
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

# Pattern
The `pattern` keyword specifies how to invoke the command. The given `Regex` must match the
message contents after having removed the command prefix. By default, it's the command name.

# Command Help
The `help` keyword specifies a help string which can be used by [`add_help!`](@ref).

# Argument Parsing
The `parsers` keyword specifies the parsers of the command arguments, and can contain both
types and functions. If `pattern` contains captures, then they are run through the parsers
before being passed into the handler. For repeating arguments, see [`Splat`](@ref).

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
Parsing two numeric arguments:
```julia
add_command!(
    c, :mult, (c, m, a, b) -> reply(c, m, string(a * b));
    pattern=r"^mult (.+) (.+)", parsers=[Float64, Float64],
)
```
Splatting some comma-separated numbers:
```julia
add_command!(
    c, :sum, (c, m, xs...) -> reply(c, m, string(sum(collect(xs))));
    pattern=r"^sum (.*)", parsers=[Splat(Float64, ',')],
)
```
"""
function add_command!(
    c::Client,
    name::Symbol,
    func::Function;
    pattern::Regex=Regex("^$name"),
    help::AbstractString="",
    parsers::Vector=[],
    n::Union{Int, Nothing}=nothing,
    timeout::Union{Period, Nothing}=nothing,
    compile::Bool=false,
    kwargs...,
)
    if !any(methods(func)) do m
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

    function predicate(c::Client, e::MessageCreate)
        isempty(e.message.content) && return false

        pfx = prefix(c, e.message.guild_id)
        startswith(e.message.content, pfx) || return false

        id = me(c) === nothing ? nothing : me(c).id
        !ismissing(e.message.author) && e.message.author.id == id && return false

        m = match(pattern, noprefix(e.message.content, pfx))
        m === nothing && return false

        return try
            parsecaps(parsers, m.captures)
            true
        catch e
            kws = logkws(c; cmd=name, exception=(e, catch_backtrace()))
            @warn "Parsers raised an exception" kws...
            false
        end
    end

    function handler(c::Client, e::MessageCreate)
        nopfx = noprefix(e.message.content, prefix(c, e.message.guild_id))
        m = match(pattern, nopfx)
        caps = parsecaps(parsers, m === nothing ? [] : m.captures)
        func(c, e.message, caps...)
    end

    cmd = Command(Handler{MessageCreate}(handler, predicate, n, timeout, false), name, help)
    puthandler!(c, cmd, name, compile; kwargs...)
end

function add_command!(
    func::Function,
    c::Client,
    name::Symbol;
    pattern::Regex=Regex("^$name"),
    help::AbstractString="",
    parsers::Vector=[],
    n::Union{Int, Nothing}=nothing,
    timeout::Union{Period, Nothing}=nothing,
    compile::Bool=false,
    kwargs...
)
    add_command!(
        c, name, func;
        pattern=pattern, help=help, parsers=parsers,
        n=n, timeout=timeout, compile=compile, kwargs...,
    )
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

Add a help command.

# Keywords
- `pattern::Regex`: The command pattern (see [`add_command!`](@ref)).
- `help::AbstractString`: Help for the help command.
- `nohelp::AbstractString`: Help for commands without their own help string.
- `nocmd::AbstractString`: Help for commands that aren't found.
"""
function add_help!(
    c::Client;
    pattern::Regex=r"^help(?: (.+))?",
    help::AbstractString="Show this help message",
    nohelp::AbstractString="No help provided",
    nocmd::AbstractString="Command not found",
)
    function handler(c::Client, m::Message, names::AbstractString...)
        sort!(collect(names))
        len = maximum(length, names)
        cmds = get(c.handlers, MessageCreate, Dict())
        io = IOBuffer()

        for name in names
            padded = lpad(name, len)
            cmd = get(cmds, Symbol(name), nothing)
            if cmd isa Command
                println(io, padded, ": ", isempty(cmd.help) ? nohelp : cmd.help)
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
        pattern=pattern, help=help, compile=true,
        message=mock(Message; content=prefix(c) * "help"), parsers=[Splat()],
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
