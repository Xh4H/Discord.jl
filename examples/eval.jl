# Fair warning: This program lets you execute arbitrary code on your computer.

module Eval

using Discord

# Set this environment variable or replace with your own user ID.
const USER = parse(Discord.Snowflake, get(ENV, "DISCORD_USER_ID", "1234567890"))

module Sandbox end

# Format some output into a code block.
function codeblock(val)
    s = val === nothing ? "nothing" : string(val)
    return "```julia\n$s\n```"
end

# Parse code into an expression.
function parsecode(code::AbstractString)
    return try
        Meta.parse("begin $code end")
    catch e
        :(sprint(showerror, $e))
    end
end

# Evaluate an expression and reply with the result.
function eval_codeblock(c::Client, msg::Message, code::Expr)
    if msg.author.id != USER
        reply(c, msg, "Only user $USER can run this command.")
        return
    end

    result = try
        @eval Sandbox $code
    catch e
        sprint(showerror, e)
    end

    reply(c, msg, codeblock(result))
end

function main()
    c = Client(ENV["DISCORD_TOKEN"])
    set_prefix!(c, '!')
    add_command!(
        c, :eval, eval_codeblock;
        pattern=r"^eval ```(?:julia)?\n(.*)\n```", args=[parsecode],
    )
    open(c)
    return c
end

end

if abspath(PROGRAM_FILE) == @__FILE__
    c = Eval.main()
    wait(c)
end
