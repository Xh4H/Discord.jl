# Fair warning: This program lets anyone execute code on your computer.
# It's just a demo!

module Eval

using Discord

const CODE_BLOCK = r"```(?:julia)?\n(.*)\n```"s

module Sandbox
set_message(m) = (global message = m)
set_channel(c) = (global channel = c)
set_guild(g) = (global guild = g)
set_author(a) = (global author = a)
set_member(m) = (global member = m)
set_client(c) = (global client = c)
end

function codeblock(val; jl::Bool)
    io = IOBuffer()
    print(io, val === nothing ? "nothing" : val)
    return "```$(jl ? "julia" : "")\n$(String(take!(io)))\n```"
end

function eval_codeblock(c::Client, msg::Discord.Message)
    if msg.author.id == 191442101135867906
        m = match(CODE_BLOCK, msg.content)

        if m === nothing
            m = msg.content[(firstindex(msg.content) + 4):lastindex(msg.content)]
        else
            m = first(m.captures)
        end

        code = replace(m, '\n' => ';')
        ex = try
            Meta.parse(code)
        catch e
            return reply(c, msg, codeblock(sprint(showerror, e); jl=true))
        end

        Sandbox.set_message(msg)
        Sandbox.set_channel(fetchval(retrieve(c, DiscordChannel, msg.channel_id)))
        Sandbox.set_guild(fetchval(retrieve(c, Guild, msg.guild_id)))
        Sandbox.set_author(msg.author)
        Sandbox.set_member(msg.member)
        Sandbox.set_client(c)

        result = try
            @eval Sandbox $ex
        catch e
            sprint(showerror, e)
        end
        
        content = "$(codeblock(result; jl=true))"
        reply(c, msg, content)
    end
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
