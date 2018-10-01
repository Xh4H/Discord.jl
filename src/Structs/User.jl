module User
    import ..Request


    function get(id)
        return Request.createRequest("GET", "/users/$id")
    end
end
