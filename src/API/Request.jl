module Request
    using HTTP
    import JSON

    const BASE_URL = "https://discordapp.com/api/v7/"

    mutable struct APIRequest
        token
    end

    client = APIRequest("")

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

        try
            response = HTTP.request(method, url, headers, payload)
            return String(response.body) |> JSON.parse
        catch err
            body = err.response.body
            return String(body) |> JSON.parse
        end
    end

    function sendMessage(channelID, content)
        payload = Dict("content" => content)
        return createRequest("POST", "channels/$channelID/messages", payload)
    end

    function getToken()
        return token
    end
end
