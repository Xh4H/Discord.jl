const HEADERS = Dict("User-Agent" => "Discord.jl", "Content-Type" => "application/json")
const SHOULD_SEND = Dict(:PATCH => true, :POST => true, :PUT => true)

"""
A wrapper around a response from the REST API. Every function which wraps a Discord REST
API endpoint returns a `Future` which will contain a value of this type. To retrieve the
`Response` from the `Future`, use `fetch`.

# Fields
- `val::Union{T, Nothing}`: The object contained in the HTTP response. For example, for a
  call to [`get_message`](@ref), this value will be a [`Message`](@ref).
- `success::Bool`: The state of the request. If `true`, then it is safe to access `val`.
- `http_response::Union{HTTP.Messages.Response, Nothing}`: The underlying HTTP response.
  If no HTTP request was made in the case of a cache hit, it is `nothing`.
"""
struct Response{T}
    val::Union{T, Nothing}
    success::Bool
    http_response::Union{HTTP.Messages.Response, Nothing}
end

# HTTP response with no body.
function Response{Nothing}(r::HTTP.Messages.Response)
    return Response{Nothing}(nothing, r.status < 300, r)
end

# HTTP response with body (maybe).
function Response{T}(r::HTTP.Messages.Response) where T
    r.status == 204 && return Response{T}(nothing, true, r)
    r.status >= 300 && return Response{T}(nothing, false, r)

    data = JSON.parse(String(copy(r.body)))
    val, TT = data isa Vector ? (T.(data), Vector{T}) : (T(data), T)
    return Response{TT}(val, true, r)
end

# Cache hit.
function Response{T}(val::T) where T
    f = Future()
    put!(f, Response{T}(val, true, nothing))
    return f
end

# HTTP request with no expected response body.
function Response(
    c::Client,
    method::Symbol,
    endpoint::AbstractString;
    body="",
    params...
)
    return Response{Nothing}(c, method, endpoint; body=body, params...)
end

# HTTP request.
function Response{T}(
    c::Client,
    method::Symbol,
    endpoint::AbstractString;
    body="",
    params...
) where T
    f = Future()

    @async begin
        url = "$DISCORD_API/v$(c.version)$endpoint"
        if !isempty(params)
            url *= "?" * HTTP.escapeuri(params)
        end
        headers = copy(HEADERS)
        headers["Authorization"] = c.token
        args = [method, url, headers]
        get(SHOULD_SEND, method, false) && push!(args, json(body))

        # TODO: Rework rate limiting. Only one request should go through at a time.
        # To think about:
        # - Multiple shards share the same rate limit.
        # - Expect 429s will still happen and handle them nicely.
        # - Rate limit of n = Base.Semaphore(n)?
        #   What happens when the rate limit resets?
        # Anyone who was waiting for it is free to go (and we should have guaranteed that
        # there were < n waiters) so we can't just create a brand new semaphore.
        # - Each bucket has a task queue?
        # Since we can't really predict the rate limits, we should probably limit requests
        # to one at a time with a single lock.

        while islimited(c.limiter, method, endpoint)
            wait(c.limiter, method, endpoint)
        end

        r = HTTP.request(args...; status_exception=false)
        update(c.limiter, method, endpoint, r)

        put!(f, Response{T}(r))
    end

    return f
end

include(joinpath("rest", "audit_log.jl"))
include(joinpath("rest", "integration.jl"))
include(joinpath("rest", "invite.jl"))
include(joinpath("rest", "channel.jl"))
include(joinpath("rest", "member.jl"))
include(joinpath("rest", "message.jl"))
include(joinpath("rest", "overwrite.jl"))
include(joinpath("rest", "role.jl"))
include(joinpath("rest", "user.jl"))
include(joinpath("rest", "webhook.jl"))
include(joinpath("rest", "guild.jl"))
