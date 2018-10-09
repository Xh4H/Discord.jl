export create_request

import JSON

headers = Dict(
    "Authorization" => "",
    "User-Agent" => "JuliCord 0.1",
    "Content-Type" => "application/json"
)

shouldSendPayload = Dict(
    "PATCH" => true,
    "POST" => true,
    "PUT" => true
)

function create_request(c::Client, method::String, endpoint::String, payload = "", query = "", files = "")
    url = DISCORD_API * endpoint
    if haskey(shouldSendPayload, method) && shouldSendPayload[method]
        payload = payload |> JSON.json
    end

    # Treat query if exist (add query to url (url?bla=ble&..))
    if !isempty(query)
        url *= "?$(HTTP.escapeuri(query))"
    end

    if isempty(headers["Authorization"])
        headers["Authorization"] = "$(c.token)"
    end

    return try
        response = HTTP.request(method, url, headers, payload)
        String(response.body) |> JSON.parse
    catch err
        println(err)
        if err.response != nothing
            if err.response.status == 400
                Dict("message" => "400: Bad Request")
            else
                err.response.body |> String |> JSON.parse
            end
        else
            err
        end
    end
end
