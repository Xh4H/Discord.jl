module User
    import ..Request
    import ..Client

    function get(id)
        if haskey(Client.users, id)
            return Client.users[id]
        else
            return Request.createRequest("GET", "/users/$id")
        end
    end
end
