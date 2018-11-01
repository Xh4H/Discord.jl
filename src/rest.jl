const HEADERS = Dict("User-Agent" => "Discord.jl", "Content-Type" => "application/json")
const SHOULD_SEND = Dict(:PATCH => true, :POST => true, :PUT => true)
const RATELIMITED = ErrorException("rate limited")

"""
A wrapper around a response from the REST API. Every function which wraps a Discord REST
API endpoint returns a `Future` which will contain a value of this type. To retrieve the
`Response` from the `Future`, use `fetch`.

# Fields
- `val::Union{T, Nothing}`: The object contained in the HTTP response. For example, for a
  call to [`get_channel_message`](@ref), this value will be a [`Message`](@ref).
- `success::Bool`: The state of the request. If `true`, then it is safe to access `val`.
- `http_response::Union{HTTP.Messages.Response, Nothing}`: The underlying HTTP response, if
  a request was made.
- `exception::Union{Exception, Nothing}`: The caught exception, if one is thrown.

# Example
```jldoctest
julia> using Discord; c = Client("token"); ch = 1234567890;

julia> fs = map(i -> Discord.create_message(c, ch; content=string(i)), 1:10);

julia> typeof(first(fs))
Distributed.Future

julia> typeof(fetch(first(fs)))
Discord.Response{Discord.Message}
```
"""
struct Response{T}
    val::Union{T, Nothing}
    success::Bool
    http_response::Union{HTTP.Messages.Response, Nothing}
    exception::Union{Exception, Nothing}
end

# HTTP response with no body.
function Response{Nothing}(r::HTTP.Messages.Response)
    return Response{Nothing}(nothing, r.status < 300, r, nothing)
end

# HTTP response with body (maybe).
function Response{T}(c::Client, r::HTTP.Messages.Response) where T
    if r.status == 204  # No content, but successful.
        return Response{T}(nothing, true, r, nothing)
    elseif r.status == 429  # Rate limited.
        throw(RATELIMITED)  # TODO: Make this cleaner, we shouldn't need to throw.
    elseif r.status >= 300  # Unsuccessful.
        return Response{T}(nothing, false, r, nothing)
    end

    data = JSON.parse(String(copy(r.body)))
    val, TT = data isa Vector ? (T.(data), Vector{T}) : (T(data), T)
    return Response{TT}(val, true, r, nothing)
end

# Cache hit.
function Response{T}(val::T) where T
    f = Future()
    put!(f, Response{T}(val, true, nothing, nothing))
    return f
end

# HTTP request with no expected response body.
function Response(
    c::Client,
    method::Symbol,
    endpoint::AbstractString;
    body="",
    kwargs...
)
    return Response{Nothing}(c, method, endpoint; body=body, kwargs...)
end

# HTTP request.
function Response{T}(
    c::Client,
    method::Symbol,
    endpoint::AbstractString;
    body="",
    kwargs...
) where T
    f = Future()

    @async begin
        url = "$DISCORD_API/v$(c.version)$endpoint"
        if !isempty(kwargs)
            url *= "?" * HTTP.escapeuri(kwargs)
        end
        headers = copy(HEADERS)
        headers["Authorization"] = c.token
        args = [method, url, headers]
        get(SHOULD_SEND, method, false) && push!(args, json(body))

        # TODO: Sometimes a request stalls and holds up the entire queue for minutes at a
        # time. Maybe we need some kind of external timeout mechanism, because it can be
        # far longer than HTTP's default minute. Or maybe my internet just sucks.

        # Acquire the lock, then check if we're rate limited. If we are, then release the
        # lock and wait for the reset. Once we get the lock back and we're not rate
        # limited, we can go through with the request (at that point we know we're the only
        # task requesting from that endpoint). We update the bucket (we are still the only
        # task touching the bucket) and then release the lock.

        b = bucket(c.limiter, method, endpoint)
        while true
            Base.acquire(b)
            if islimited(c.limiter, b)
                Base.release(b)
                wait(c.limiter, b)
            else
                try
                    r = HTTP.request(args...; status_exception=false)
                    update!(c.limiter, b, r)
                    put!(f, Response{T}(c, r))
                catch e
                    # If we're rate limited, then just go back to the top.
                    e == RATELIMITED && continue
                    put!(f, Response{T}(nothing, false, nothing, e))
                finally
                    Base.release(b)
                end
                break
            end
        end
    end

    return f
end

include(joinpath("rest", "audit_log.jl"))
include(joinpath("rest", "channel.jl"))
include(joinpath("rest", "emoji.jl"))
include(joinpath("rest", "guild.jl"))
include(joinpath("rest", "invite.jl"))
include(joinpath("rest", "user.jl"))
include(joinpath("rest", "voice.jl"))
include(joinpath("rest", "webhook.jl"))
