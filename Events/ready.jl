module ReadyEvent

    include("../Structs/User.jl")
    function executeEvent(client, args...)
        userData = args[1]["user"] # For some reason the first index is 1 and not 0
        a = User.construct(userData)
        println(a)
        println("I'm ready in ReadyEvent")
    end

end
