module Ping

using Discord

function on_message_create(c::Client, event::MessageCreate)
    if event.message.content == "ping"
       reply(c, event.message, "Pong!")    
    elseif event.message.content == "pong"   	  
       reply(c, event.message, "Ping!")
    end
end

function main()
    c = Client(ENV["DISCORD_TOKEN"])
    open(c)
    add_handler!(c, MessageCreate, on_message_create; tag=:ping)
    return c
end

end

if abspath(PROGRAM_FILE) == @__FILE__
    c = Ping.main()
    wait(c)
end
