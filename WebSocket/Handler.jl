module WSHandler
    include("Logger.jl")
    include("../Structs/User.jl")

    using Base
    using Dates
    import .WSLogger
    import .User
    import JSON


    function handleEvent(data, mainClient) # content is the key "d"
        eventName = data["t"]
        content = data["d"]
        #println(content)

        if eventName == "READY"
            @async begin
                try
                    user = content["user"]
                    username = user["username"]
                    id = user["id"]
                    discriminator = user["discriminator"]
                    avatar = user["avatar"]
                    bot = user["bot"]
                    userObject = User.Self(username, id, discriminator, avatar, bot)

                    println("The client's username is $(userObject.username)")
                catch err
                    println(err)
                end
            end

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
