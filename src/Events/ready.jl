module ReadyEvent

    include("../Structs/User.jl")
    function executeEvent(mainClient, content)
        userData = content["user"] # For some reason the first index is 1 and not 0
        a = User.construct(userData)
        mainClient.setUser(a)
        mainClient.send("READY")
    end

end
