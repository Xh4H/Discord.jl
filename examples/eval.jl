# Fair warning: This program lets you execute arbitrary code on your computer.

module Eval

using Discord

# Set this environment variable or replace with your own user ID.
const USER = parse(Discord.Snowflake, get(ENV, "DISCORD_USER_ID", 1234567890))
const CODE_BLOCK = r"```(?:julia)?\n(.*)\n```"s

module Sandbox end

function codeblock(val)
    io = IOBuffer()
    print(io, val === nothing ? "nothing" : val)
    return "```julia\n" * String(take!(io)) * "\n```"
end

function eval_codeblock(c::Client, msg::Discord.Message)
    if msg.author.id != USER
        reply(c, msg, "Only user $USER can run this command.")
        return
    end

    m = match(CODE_BLOCK, msg.content)

    m = if m === nothing
        reply(c, msg, "That's not a code block.")
        return
    else
        first(m.captures)
    end

    code = replace(m, '\n' => ';')
    ex = try
        Meta.parse(code)
    catch e  # Parsing error.
        reply(c, msg, codeblock(sprint(showerror, e)))
        return
    end

    result = try
        @eval Sandbox $ex
    catch e  # Runtime error.
        sprint(showerror, e)
    end

    reply(c, msg, codeblock(result))
end

function main()
    c = Client(ENV["DISCORD_TOKEN"])
    add_command!(c, "!eval", eval_codeblock)
    open(c)
    return c
end

end

if abspath(PROGRAM_FILE) == @__FILE__
    c = Eval.main()
    wait(c)
end
