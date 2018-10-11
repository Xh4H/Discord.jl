const request_headers = Dict(
    "User-Agent" => "Julicord 0.1",
    "Content-Type" => "application/json",
)

const should_send = Dict(
    :PATCH => true,
    :POST => true,
    :PUT => true,
)

"""
A wrapper around responses from the REST API.

# Fields
- `val::Union{T, Nothing}`: The object contained in the HTTP response. For example, a call
  to [`get_message`](@ref) will return a `Response{Message}` for which this value is a
  [`Message`](@ref). If `success` is `false`, it is `nothing`.
- `success::Bool`: The success state of the request. If this is `true`, then it is safe to
  access `val`.
- `cache_hit::Bool`: Whether `val` came from the cache.
- `http_response`: The underlying HTTP response. If `success` is true, then this is a
  `HTTP.Messages.Response`. Otherwise, it is a `HTTP.ExceptionRequest.StatusError`.
  If `cache_hit` is `true`, it is `nothing`.
"""
struct Response{T}
    val::Union{T, Nothing}
    success::Bool
    cache_hit::Bool
    http_response::Union{HTTP.Messages.Response, HTTP.ExceptionRequest.StatusError, Nothing}
end

# HTTP status error.
function Response{T}(e::HTTP.ExceptionRequest.StatusError) where T
    return Response{T}(nothing, false, false, e)
end

# Successful HTTP request with no body.
function Response{Nothing}(r::HTTP.Messages.Response)
    return Response{Nothing}(nothing, true, false, r)
end

# Successful HTTP request.
function Response{T}(r::HTTP.Messages.Response) where T
    body = JSON.parse(String(r.body))
    val, TT = body isa Vector ? (T.(body), Vector{T}) : (T(body), T)
    Response{TT}(val, true, false, r)
end

# Cache hit.
function Response{T}(val::T) where T
    return Response{T}(val, true, true, nothing)
end

# HTTP request with no expected response body.
function Response(c::Client, method::Symbol, endpoint::AbstractString; body::Dict=Dict(), params...)
    return Response{Nothing}(c, mthod, endpoint; body=body, params...)
end

# HTTP request.
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
