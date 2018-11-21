# TODO: Make this more comprehensive. For now look at eval.jl or the add_command! docs.

module Commands

using Discord

function main()
    c = Client(ENV["DISCORD_TOKEN"])
    add_command!(c, r"^echo (.+)") do c, msg, noprefix
        reply(c, msg, noprefix)
    end
    open(c)
    return c
end

end

if abspath(PROGRAM_FILE) == @__FILE__
    c = Commands.main()
    wait(c)
end
