const request_headers = Dict(
    "User-Agent" => "Julicord 0.1",
    "Content-Type" => "application/json",
)

const should_send = Dict(
    :PATCH => true,
    :POST => true,
    :PUT => true,
)

struct Response{T}
    val::Union{T, Nothing}
    success::Bool
    cache_hit::Bool
    http_response::Union{HTTP.Messages.Response, HTTP.ExceptionRequest.StatusError, Nothing}
end

function Response{Nothing}(e::HTTP.ExceptionRequest.StatusError)
    return Response{Nothing}(nothing, false, false, e)
end

function Response{T}(e::HTTP.ExceptionRequest.StatusError) where T
    return Response{T}(nothing, false, false, e)
end

function Response{Nothing}(r::HTTP.Messages.Response)
    return Response{Nothing}(nothing, true, false, r)
end

function Response{T}(r::HTTP.Messages.Response) where T
    body = JSON.parse(String(r.body))
    val, TT = body isa Vector ? (T.(body), Vector{T}) : (T(body), T)
    Response{TT}(val, true, false, r)
end

function Response{T}(val::T) where T
    return Response{T}(val, true, true, nothing)
end

function Response(c::Client, method::Symbol, endpoint::AbstractString; body::Dict=Dict(), params...)
    return Response{Nothing}(c, mthod, endpoint; body=body, params...)
end

function Response{T}(
    c::Client,
    method::Symbol,
    endpoint::AbstractString;
    body::Dict=Dict(),
    params...,
) where T
    url = DISCORD_API * endpoint
    if !isempty(params)
        url *= "?" * HTTP.escapeuri(params)
    end

    headers = copy(request_headers)
    headers["Authorization"] = c.token

    args = [method, url, headers]
    get(should_send, method, false) && push!(args, json(body))
    return try
        Response{T}(HTTP.request(args...))
    catch e
        e isa HTTP.ExceptionRequest.StatusError || rethrow(e)
        Response{T}(e)
    end
end

include(joinpath("rest", "invite.jl"))
include(joinpath("rest", "channel.jl"))
include(joinpath("rest", "message.jl"))
