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
            username = content["user"]["username"]
            WSLogger.log("Client is ready as: $username", "Log")
        else
            WSLogger.log("Unhandled event $eventName:", "Warning")
        end
    end

end
