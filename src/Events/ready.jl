module ReadyEvent
    include("../Structs/User.jl")
    
    function executeEvent(mainClient, content)
        mainClient.setUser(content["user"])
        mainClient.send("READY")
    end
end
