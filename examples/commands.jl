module Commands

using Discord

function echo(c::Client, msg::Message)
    content = lstrip(msg.content[6:end])  # Trim off the command part.
    reply(c, msg, content)
end

function main()
    c = Client(ENV["DISCORD_TOKEN"])
    add_command!(c, "!echo", echo)
    open(c)
    return c
end

end

if abspath(PROGRAM_FILE) == @__FILE__
    c = Commands.main()
    wait(c)
end
