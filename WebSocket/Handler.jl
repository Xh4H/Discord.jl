module WSHandler
    include("Logger.jl")

    using Base
    using Dates
    import .WSLogger

    import JSON


    function handleEvent(data) # content is the key "d"
        eventName = data["t"]
        content = data["d"]
        eventName = lowercase(eventName) # We treat event names in lowercase

        if eventName == "ready"
            println("TEST")
            clientName = "$(content["d"]["username"])#$(content["d"]["discriminator"])" #Miss Julia#9120
            WSLogger.log("Client is ready $clientName", "Log")
        else
            log("Unhandled event $eventName:", "Warning")
        # if eventName == "ready"
        #     clientDiscordName = "$(content["d"]["username"])#$(content["d"]["discriminator"])" #Miss Julia#9120
        #     log("Logged in successfully as $clientDiscordName.", "Log")
        # else
        #     log("Received unhandled event: $eventName", "Log")
        end
    end

end
