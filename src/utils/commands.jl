export add_command!

"""
    add_command!(
        c::Client,
        prefix::AbstractString,
        func::Function;
        tag::Symbol=gensym(),
        n::Union{Int, Nothing}=nothing,
        timeout::Union{Period, Nothing}=nothing,
        compile::Bool=false,
    )

Add a text command handler. The handler function should take two arguments: A
[`Client`](@ref) and a [`Message`](@ref). The keyword arguments are a subset of those to
[`add_handler!`](@ref). `do` syntax is also accepted.
"""
function add_command!(
    c::Client,
    prefix::AbstractString,
    func::Function;
    tag::Symbol=gensym(),
    n::Union{Int, Nothing}=nothing,
    timeout::Union{Period, Nothing}=nothing,
    compile::Bool=false,
)
    if !hasmethod(func, (Client, Message))
        throw(ArgumentError("Handler function must accept (::Client, ::Message)"))
    end

    function predicate(c::Client, e::MessageCreate)
        id = me(c) === nothing ? me(c).id : nothing
        return e.message.author.id != id && startswith(e.message.content, prefix)
    end
    handler(c::Client, e::MessageCreate) = func(c, e.message)

    add_handler!(
        c, MessageCreate, handler;
        tag=tag, pred=predicate, n=n, timeout=timeout, compile=compile,
    )
end

function add_command!(
    func::Function,
    c::Client,
    prefix::AbstractString,
    tag::Symbol=gensym(),
    n::Union{Int, Nothing}=nothing,
    timeout::Union{Period, Nothing}=nothing,
    compile::Bool=false,
)
    return add_command!(c, prefix, func; tag=tag, n=n, timeout=timeout, compile=compile)
end

# TODO: A much nicer command framework.
