module Events

using Discord

function on_message_create(c::Client, e::MessageCreate)
    e.message.content == "ping" && reply(c, e.message, "pong")
end

function main()
    c = Client(ENV["DISCORD_TOKEN"])
    add_handler!(c, MessageCreate, on_message_create)
    open(c)
    return c
end

end

if abspath(PROGRAM_FILE) == @__FILE__
    c = Events.main()
    wait(c)
end
