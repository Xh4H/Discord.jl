module Client

    include("./WebSocket/Manager.jl")
    include("./Utils/Emitter.jl")
    include("./API/Request.jl")

    evs = Events()

    import .WSManager
    import .Request: client, APIRequest

    setToken(t) = (global token = t)
    setUsers(u) = (global users = u)
    setChannels(c) = (global channels = c)
    setGuilds(g) = (global guilds = g)
    setPresences(p) = (global presences = p)
    setEmojis(e) = (global emojis = e)
    setUser(u) = (global user = u)

    function init(token::String)
        setToken(token) # set the token in global scope (Client.token is valid)
        client.token = token # Pass the token request handler
        connect()
    end

    function connect()
        WSManager.start(Client)
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
