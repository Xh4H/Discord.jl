module Message
    import ..Request
    import ..User

    function pretty(data)
        data["author"] = User.get(data["author"]["id"])

        println(data)
        return data
    end

end
