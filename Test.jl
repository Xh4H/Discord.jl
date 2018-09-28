include("Client.jl")

import .Client

function ready()
    t = @async Client.Request.sendMessage("494962347434049539", "Hey!")
    @async Base.show_backtrace(STDOUT, t.backtrace)
    println("good morning")
end

function guildCreate(guild)
    println(guild["id"])
end

function createMessage(message)
    if message["channel_id"] == "494962347434049539" && message["author"]["id"] != "494962400764755985"
        println("test")
        @async Client.Request.sendMessage(message["channel_id"], "Hey!")
    end
end

Client.on("READY", ready)
Client.on("GUILD_CREATE", guildCreate)
Client.on("MESSAGE_CREATE", createMessage)

a = Client.init("token")
