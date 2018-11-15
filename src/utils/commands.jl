export add_command!,
    delete_command!,
    add_help!,
    set_prefix!

struct Command <: AbstractHandler{MessageCreate}
    h::Handler{MessageCreate}
    name::Symbol
    help::AbstractString
end

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
        args::Vector=[],
        n::Union{Int, Nothing}=nothing,
        timeout::Union{Period, Nothing}=nothing,
        compile::Bool=false,
    )

Add a text command handler. `do` syntax is also accepted.

# Handler Function
The handler function must accept a [`Client`](@ref) and a [`Message`](@ref). Additionally,
it can accept any number of additional arguments, which are captured from `pattern`
and parsed with `args` (see below).

# Pattern
The `pattern` keyword specifies how to invoke the command. The given `Regex` must match the
message contents after having removed the command prefix. By default, it's the command name.

# Command Help
The `help` keyword specifies a help string which can be used by [`add_help!`](@ref).

# Argument Parsing
The `args` keyword specifies the types of the command arguments, and can contain both types
and functions. If `pattern` contains captures, then they are converted to the type or run
through the function before being passed into the handler.

Additional keyword arguments are a subset of those to [`add_handler!`](@ref).

# Examples
```
TODO
```
"""
function add_command!(
    c::Client,
    name::Symbol,
    func::Function;
    pattern::Regex=Regex("^$name"),
    help::AbstractString="",
    args::Vector=[],
    n::Union{Int, Nothing}=nothing,
    timeout::Union{Period, Nothing}=nothing,
    compile::Bool=false,
)
    if !any(methods(func).ms) do m
        length(m.sig.types) < 3 && return false
        return Client <: m.sig.types[2] && Message <: m.sig.types[3]
    end
        throw(ArgumentError("Handler function must accept (::Client, ::Message, ...)"))
    end
    if !all(arg -> arg isa Base.Callable, args)
        throw(ArgumentError("Argument must be callable"))
    end

    function predicate(c::Client, e::MessageCreate)
        prefix, noprefix = splitprefix(c, e)
        startswith(e.message.content, prefix) || return false
        id = me(c) === nothing ? me(c).id : nothing
        e.message.author.id == id && return false
        m = match(pattern, noprefix)
        m === nothing && return false
        return parsecaps!(Vector{Any}(m.captures), args)
    end

    function handler(c::Client, e::MessageCreate)
        noprefix = splitprefix(c, e)[2]
        caps = Vector{Any}(match(pattern, noprefix).captures)
        parsecaps!(caps, args)
        func(c, e.message, caps...)
    end

    cmd = Command(Handler{MessageCreate}(handler, predicate, n, timeout, false), name, help)
    puthandler!(c, cmd, name, compile)
end

function add_command!(
    func::Function,
    c::Client,
    name::Symbol;
    pattern::Regex=Regex("^$name"),
    help::AbstractString="",
    args::Vector=[],
    n::Union{Int, Nothing}=nothing,
    timeout::Union{Period, Nothing}=nothing,
    compile::Bool=false,
)
    return add_command!(
        c, name, func;
        pattern=pattern, help=help, args=args, n=n, timeout=timeout, compile=compile,
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
  The optional capture group is important.
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
    function handler(c::Client, m::Message, rest::AbstractString)
        names = split(rest, " ")
        sort!(names)
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

    function handler(c::Client, m::Message, ::Nothing)
        cmds = collect(get(c.handlers, MessageCreate, Dict()))
        filter!(p -> p.second isa Command, cmds)
        handler(c, m, join(map(p -> string(p.second.name), cmds), " "))
    end

    add_command!(c, :help, handler; pattern=pattern, help=help, compile=true)
end

"""
    set_prefix!(c::Client, prefix::String)
    set_prefix!(c::Client, prefix::String, guild::Union{Guild, Integer})

Set [`Client`](@ref)'s command prefix. If a [`Guild`](@ref) or its ID is supplied, then the
prefix only applies to that guild.
"""
set_prefix!(c::Client, prefix::AbstractString) = c.p_global = prefix
set_prefix!(c::Client, prefix::AbstractString, guild::Integer) = c.p_guilds[guild] = prefix
set_prefix!(c::Client, prefix::AbstractString, g::Guild) = set_prefix!(c, prefix, g.id)

# Get the prefix and the rests of the message.
function splitprefix(c::Client, e::MessageCreate)
    prefix = get(c.p_guilds, e.message.guild_id, c.p_global)
    noprefix = e.message.content[length(prefix)+1:end]
    return prefix, noprefix
end

# Parse command arguments. Mutates the captures and returns the success state.
function parsecaps!(caps::Vector{Any}, args::Vector)
    local success = true
    for (i, (cap, arg)) in enumerate(zip(caps, args))
        try
            caps[i] = if arg isa Type && hasmethod(parse, (Type{arg}, AbstractString))
                parse(arg, cap)
            else
                arg(cap)
            end
        catch
            success = false
        end
    end
    return success
end
