module Request
    using HTTP
    using JSON

    global token = ""
    const BASE_URL = "https://discordapp.com/api/v7"

    mutable struct APIRequest
        token
    end

    global client = APIRequest("")

    function sendMessage(channelID, content)
        println(client)

        payloadSend = Dict(
            "content" => content
        ) |> JSON.json

        headers = Dict(
            "Authorization" => "Bot $(client.token)",
            "User-Agent" => "JuliCord 0.1",
            "Content-Type" => "application/json",
            "Content-Length" => payloadSend |> length
        )

        return HTTP.request("POST", "$BASE_URL/channels/$channelID/messages", headers, payloadSend)
    end

    function getToken()
        return token
    end
end
