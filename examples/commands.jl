module Commands

using Discord

const COMMAND = "!echo"

function echo(c::Client, msg::Message)
    content = lstrip(msg.content[length(COMMAND)+1:end])
    reply(c, msg, content)
end

function main()
    c = Client(ENV["DISCORD_TOKEN"])
    add_command!(c, COMMAND, echo)
    open(c)
    return c
end

end

if abspath(PROGRAM_FILE) == @__FILE__
    c = Commands.main()
    wait(c)
end
