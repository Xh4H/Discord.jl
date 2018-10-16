# Fair warning: This program lets anyone execute code on your computer.
# It's just a demo!

module Eval

using Julicord

const CODE_BLOCK = r"```(?:julia)?\n(.*)\n```"s

module Sandbox end
codeblock(s, jl::Bool=true) = "```$(jl ? "julia" : "")\n$(repr(s))\n```"

function eval_codeblock(c::Client, msg::Julicord.Message)
    m = match(CODE_BLOCK, msg.content)
    m === nothing && return reply(c, msg, "That's not a code block.")
    code = replace(first(m.captures), '\n' => ';')

    ex = try
        Meta.parse(code)
    catch e
        return reply(c, msg, codeblock(sprint(showerror, e)))
    end

    # TODO: Capture output.

    try
        result = @eval Sandbox $ex
        reply(c, msg, codeblock(result))
    catch e
        return reply(c, msg, codeblock(sprint(showerror, e)))
    end
end

function main()
    c = Client(ENV["DISCORD_TOKEN"])
    add_command!(c, "!eval", eval_codeblock)
    open(c)
    wait(c)
end

end

if abspath(PROGRAM_FILE) == @__FILE__
    Eval.main()
end
