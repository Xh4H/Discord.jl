module ReadyEvent

    include("../Structs/User.jl")
    function executeEvent(client, content, mainClient)
        userData = content["user"] # For some reason the first index is 1 and not 0
        a = User.construct(userData)
        println(a)
        println("I'm ready in ReadyEvent")
        mainClient.send("READY")
    end

end
