module Client

    include("./WebSocket/Manager.jl")
    import .WSManager

    struct Self
        token::String
    end

    function init(token::String)
         structure = Self(token)
         connect(structure)
    end

    function connect(client::Self)
        WSManager.start(client)
    end
end
