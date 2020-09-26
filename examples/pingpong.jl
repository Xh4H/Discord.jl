module Ping

using Discord

function on_message_create(client::Client, event::MessageCreate)
    if event.message.content == "ping"
       reply(client, event.message, "Pong!")    
    elseif event.message.content == "pong"   	  
       reply(client, event.message, "Ping!")
    end
end

function main()
    client = Client(ENV["DISCORD_TOKEN"])
    open(client)
    add_handler!(client, MessageCreate, on_message_create; tag=:ping)
    return client
end

end

if abspath(PROGRAM_FILE) == @__FILE__
    client = Ping.main()
    wait(client)
end
