export add_command!

"""
    add_command!(
        c::Client,
        prefix::AbstractString,
        func::Function;
        tag::Symbol=gensym(),
        expiry::Union{Int, Period, Nothing}=nothing,
    )
    add_command!(
        func::Function;
        c::Client,
        prefix::AbstractString,
        tag::Symbol=gensym(),
        expiry::Union{Int, Period, Nothing}=nothing,
    )


Add a text command handler. The handler function should take two arguments: A
[`Client`](@ref) and a [`Message`](@ref). The keyword arguments are identical to
[`add_handler!`](@ref). `do` syntax is also accepted.
"""
function add_command!(
    c::Client,
    prefix::AbstractString,
    func::Function;
    tag::Symbol=gensym(),
    expiry::Union{Int, Period, Nothing}=nothing,
)
    if !hasmethod(func, (Client, Message))
        throw(ArgumentError("Handler function must accept (::Client, ::Message)"))
    end

    function handler(c::Client, e::MessageCreate)
        e.message.author.id == me(c).id && return
        startswith(e.message.content, prefix) || return
        func(c, e.message)
    end

    add_handler!(c, MessageCreate, handler; tag=tag, expiry=expiry)
end

function add_command!(
    func::Function,
    c::Client,
    prefix::AbstractString,
    tag::Symbol=gensym(),
    expiry::Union{Int, Period, Nothing}=nothing,
)
    return add_command!(c, prefix, func; tag=tag, expiry=expiry)
end

# TODO: A much nicer command framework.
