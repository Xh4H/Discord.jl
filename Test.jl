include("Client.jl")

function ready()
    Client.Request.sendMessage("494962347434049539", "Dabidi dibidi du")
    println("good morning")
    println(Client.user[:username]) # Miss Julia
end

function guildCreate(guild)
    println(guild["id"])
end

function createMessage(message)
    if message["channel_id"] == "494962347434049539" && message["author"]["id"] != "494962400764755985"
        Client.Request.sendMessage(message["channel_id"], "Hey!")
    end
end

Client.on("READY", ready)
Client.on("GUILD_CREATE", guildCreate)
Client.on("MESSAGE_CREATE", createMessage)

Client.init("token")
