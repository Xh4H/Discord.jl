module Request
    using HTTP
    using JSON

    const BASE_URL = "https://discordapp.com/api/v7/"

    mutable struct APIRequest
        token
    end

    setToken(t) = (global token = t)

    headers = Dict(
        "Authorization" => "",
        "User-Agent" => "JuliCord 0.1",
        "Content-Type" => "application/json"
    )

    function createRequest(method::String, endpoint::String, payload = "", query = "", files = "")
        url = BASE_URL * endpoint
        payload = payload |> JSON.json

        # Treat query if exist (add query to url (url?bla=ble&..)

        if headers["Authorization"] == ""
            headers["Authorization"] = "Bot $(client.token)"
        end

        return HTTP.request(method, url, headers, payload)
    end

    function sendMessage(channelID, content)
        payload = Dict("content" => content)
        return createRequest("POST", "channels/$channelID/messages", payload)
    end

    function getToken()
        return token
    end
end
