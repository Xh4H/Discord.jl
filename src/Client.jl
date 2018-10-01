module Client

    include("./Utils/Emitter.jl")
    import ..Request
    import ..WSManager

    evs = Events()

    setToken(t) = (global token = t)
    setUsers(u) = (global users = u)
    setChannels(c) = (global channels = c)
    setGuilds(g) = (global guilds = g)
    setEmojis(e) = (global emojis = e)
    setUser(u) = (global user = u)

    function init(token::String)
        setToken(token) # set the token in global scope (Client.token is valid)
        setUsers(Dict())
        setChannels(Dict())
        setGuilds(Dict())
        setEmojis(Dict())
        setUser(Dict())


        Request.client.token = token # Pass the token request handler
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
