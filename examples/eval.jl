# Fair warning: This program lets anyone execute code on your computer.
# It's just a demo!

module Eval

using Discord

const CODE_BLOCK = r"```(?:julia)?\n(.*)\n```"s

module Sandbox end

function codeblock(val; jl::Bool)
    io = IOBuffer()
    print(io, val === nothing ? "nothing" : val)
    return "```$(jl ? "julia" : "")\n$(String(take!(io)))\n```"
end

function eval_codeblock(c::Client, msg::Discord.Message)
    m = match(CODE_BLOCK, msg.content)
    m === nothing && return reply(c, msg, "That's not a code block.")
    code = replace(first(m.captures), '\n' => ';')

    ex = try
        Meta.parse(code)
    catch e
        return reply(c, msg, codeblock(sprint(showerror, e); jl=true))
    end

    # TODO: This doesn't work. Why?
    old_stdout = stdout
    r, w = redirect_stdout()
    result = try
        @eval Sandbox $ex
    catch e
        sprint(showerror, e)
    end

    output = bytesavailable(r) > 0 ? readavailable(r) : "No output"
    redirect_stdout(old_stdout)

    content = """
    Output:
    $(codeblock(output; jl=false))
    Result:
    $(codeblock(result; jl=true))
    """
    reply(c, msg, content)
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
