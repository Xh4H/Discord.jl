module PingPong

using Discord

function on_message_create(c::Client, e::MessageCreate)
    e.message.content == "ping" && reply(c, e.message, "pong")
end

function main()
    c = Client(ENV["DISCORD_TOKEN"])
    add_handler!(c, MessageCreate, on_message_create)
    open(c)
    wait(c)
end

end

if abspath(PROGRAM_FILE) == @__FILE__
    PingPong.main()
end
