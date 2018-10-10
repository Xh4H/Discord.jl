const request_headers = Dict(
    "User-Agent" => "Julicord 0.1",
    "Content-Type" => "application/json",
)

const should_send = Dict(
    "PATCH" => true,
    "POST" => true,
    "PUT" => true,
)

function request(
    c::Client,
    method::String,
    endpoint::String;
    payload=Dict(),
    query=Dict(),
)
    url = DISCORD_API * endpoint

    if !isempty(query)
        url *= "?$(HTTP.escapeuri(query))"
    end

    headers = copy(request_headers)
    headers["Authorization"] = c.token

    return try
        resp = if get(should_send, method, false)
            HTTP.request(method, url, headers, json(payload))
        else
            HTTP.request(method, url, headers)
        end
        JSON.parse(String(resp.body))
    catch e
        # TODO: Check the type of the exception properly.
        if isdefined(e, :response) && e.response != nothing
            if e.response.status == 400
                Dict("message" => "400: Bad Request")
            else
                JSON.parse(String(e.response.body))
            end
        end
    end
end

include(joinpath("rest", "message.jl"))
