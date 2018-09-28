module Client

    include("./WebSocket/Manager.jl")
    include("./Utils/Emitter.jl")

    evs = Events()

    import .WSManager

    mutable struct Self
        token::String
    end

    function init(token::String)
        structure = Self(token)
        connect(structure)
    end

    function connect(client1::Self)
        WSManager.start(client1, Client)
    end

    function on(name::String, fn::Function)
        on(evs, name, fn)
    end

    function send(name)
        emit(evs, name)
    end

    function send(name, args...)
        emit(evs, name, args...)
    end
end
