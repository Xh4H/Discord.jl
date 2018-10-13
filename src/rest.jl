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
A wrapper around a response from the REST API.

# Fields
- `val::Union{T, Nothing}`: The object contained in the HTTP response. For example, a call
  to [`get_message`](@ref) will return a `Response{Message}` for which this value is a
  [`Message`](@ref). If `success` is `false`, it is `nothing`.
- `success::Bool`: The success state of the request. If this is `true`, then it is safe to
  access `val`.
- `cache_hit::Bool`: Whether `val` came from the cache.
- `rate_limited::Bool`: Whether the request was rate limited.
- `http_response::Union{HTTP.Messages.Response, Nothing}`: The underlying HTTP response.
  If `success` is true, it is `nothing`.
"""
struct Response{T}
    val::Union{T, Nothing}
    success::Bool
    cache_hit::Bool
    rate_limited::Bool
    http_response::Union{HTTP.Messages.Response, Nothing}
end

# HTTP response with no body.
function Response{Nothing}(r::HTTP.Messages.Response, limited::Bool)
    return Response{Nothing}(nothing, r.status < 300, false, limited, r)
end

# HTTP response with body (maybe).
function Response{T}(r::HTTP.Messages.Response, limited::Bool) where T
    r.status == 204 && return Response{T}(nothing, true, false, r)
    r.status >= 300 && return Response{T}(nothing, false, false, r.status == 429, r)

    body = JSON.parse(String(copy(r.body)))
    val, TT = body isa Vector ? (T.(body), Vector{T}) : (T(body), T)
    Response{TT}(val, true, false, limited, r)
end

# Cache hit.
function Response{T}(val::T) where T
    return Response{T}(val, true, true, false, nothing)
end

# HTTP request with no expected response body.
function Response(
    c::Client,
    method::Symbol,
    endpoint::AbstractString;
    body="",
    params...,
)
    return Response{Nothing}(c, method, endpoint; body=body, params...)
end

# HTTP request.
function Response{T}(
    c::Client,
    method::Symbol,
    endpoint::AbstractString;
    body="",
    params...,
) where T
    limited = islimited(c.limiter, method, endpoint)
    if limited
        if c.on_limit === LIMIT_IGNORE
            return Response{T}(nothing, false, false, true, nothing)
        elseif c.on_limit === LIMIT_WAIT
            wait(c.limiter, method, endpoint)
        end
    end

    url = DISCORD_API * endpoint
    if !isempty(params)
        url *= "?" * HTTP.escapeuri(params)
    end

    headers = copy(request_headers)
    headers["Authorization"] = c.token

    args = [method, url, headers]
    get(should_send, method, false) && push!(args, json(body))
    r = HTTP.request(args...; status_exception=false)
    update(c.limiter, method, endpoint, r)

    return Response{T}(r, limited)
end

include(joinpath("rest", "integration.jl"))
include(joinpath("rest", "invite.jl"))
include(joinpath("rest", "channel.jl"))
include(joinpath("rest", "member.jl"))
include(joinpath("rest", "message.jl"))
include(joinpath("rest", "overwrite.jl"))
include(joinpath("rest", "role.jl"))
include(joinpath("rest", "webhook.jl"))
