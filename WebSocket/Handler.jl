module WSHandler
    include("Logger.jl")

    using Base
    using Dates
    import .WSLogger

    import JSON


    function handleEvent(data, mainClient) # content is the key "d"
        eventName = data["t"]
        content = data["d"]
        #println(content)

        if eventName == "READY"
            username = content["user"]["username"]
            WSLogger.log("Client is ready as: $username", "Log")
            mainClient.send(eventName)
        elseif eventName == "GUILD_CREATE"
            mainClient.send(eventName, content)
        elseif eventName == "MESSAGE_CREATE"
            mainClient.send(eventName, content)
        else
            WSLogger.log("Unhandled event $eventName:", "Warning")
        end
    end

end
