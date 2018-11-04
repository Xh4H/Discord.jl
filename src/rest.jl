export fetchval

const HEADERS = Dict("User-Agent" => "Discord.jl", "Content-Type" => "application/json")
const SHOULD_SEND = Dict(:PATCH => true, :POST => true, :PUT => true)
const RATELIMITED = ErrorException("Rate limited")

"""
A wrapper around a response from the REST API. Every function which wraps a Discord REST
API endpoint returns a `Future` which will contain a value of this type. To retrieve the
`Response` from the `Future`, use `fetch` or [`fetchval`](@ref).

# Fields
- `val::Union{T, Nothing}`: The object contained in the HTTP response. For example, for a
  call to [`get_channel_message`](@ref), this value will be a [`Message`](@ref).
- `ok::Bool`: The state of the request. If `true`, then it is safe to access `val`.
- `http_response::Union{HTTP.Messages.Response, Nothing}`: The underlying HTTP response, if
  a request was made.
- `exception::Union{Exception, Nothing}`: The caught exception, if one is thrown.

# Example
```julia-repl
julia> using Discord; c = Client("token"); ch = 1234567890;

julia> fs = map(i -> Discord.create_message(c, ch; content=string(i)), 1:10);

julia> typeof(first(fs))
Distributed.Future

julia> typeof(fetch(first(fs)))
Discord.Response{Message}
```
"""
struct Response{T}
    val::Union{T, Nothing}
    ok::Bool
    http_response::Union{HTTP.Messages.Response, Nothing}
    exception::Union{Exception, Nothing}
end

# HTTP response with no body.
function Response{Nothing}(r::HTTP.Messages.Response)
    return Response{Nothing}(nothing, r.status < 300, r, nothing)
end

# HTTP response with body (maybe).
function Response{T}(c::Client, r::HTTP.Messages.Response) where T
    r.status == 429 && throw(RATELIMITED)
    r.status == 204 && return Response{T}(nothing, true, r, nothing)
    r.status >= 300 && return Response{T}(nothing, false, r, nothing)

    data = if HTTP.header(r, "Content-Type") == "application/json"
        JSON.parse(String(copy(r.body)))
    else
        copy(r.body)
    end

    val, e = tryparse(c, T, data)
    return Response{T}(val, e === nothing, r, e)
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
        kws = (
            channel=cap("channels", endpoint),
            guild=cap("guilds", endpoint),
            message=cap("messages", endpoint),
            user=cap("users", endpoint),
        )

        if c.use_cache && method === :GET
            val = get(c.state, T; kws...)
            if val !== nothing
                put!(f, Response{T}(val, true, nothing, nothing))
                return
            end
        end

        url = "$DISCORD_API/v$(c.version)$endpoint"
        if !isempty(kwargs)
            url *= "?" * HTTP.escapeuri(kwargs)
        end
        headers = copy(HEADERS)
        headers["Authorization"] = c.token
        args = [method, url, headers]
        get(SHOULD_SEND, method, false) && push!(args, json(body))

        # Acquire the lock, then check if we're rate limited. If we are, then release the
        # lock and wait for the reset. Once we get the lock back and we're not rate
        # limited, we can go through with the request (at that point we know we're the only
        # task requesting from that endpoint). We update the bucket (we are still the only
        # task touching the bucket) and then release the lock.

        b = Bucket(c.limiter, method, endpoint)
        while true
            lock(b)

            if islimited(c.limiter, b)
                unlock(b)
                wait(c.limiter, b)
            else
                try
                    r = HTTP.request(args...; status_exception=false)
                    resp = Response{T}(c, r)
                    put!(f, resp)
                    update!(c.limiter, b, r)
                    if c.use_cache && resp.ok && resp.val !== nothing
                        put!(c.state, resp.val; kws...)
                    end
                catch e
                    # If we're rate limited, then just go back to the top.
                    e == RATELIMITED && continue
                    logmsg(c, ERROR, catchmsg(e))
                    put!(f, Response{T}(nothing, false, nothing, e))
                finally
                    unlock(b)
                end

                break  # If we reached here, it means we got the request through.
            end
        end
    end

    return f
end

Base.eltype(::Response{T}) where T = T
Base.eltype(::Type{Response{T}}) where T = T

"""
    fetchval(f::Future{Response{T}}) -> Union{T, Nothing}

Shortcut for `fetch(f).val`: Fetch a [`Response`](@ref) and return its value. Note that
there are no guarantees about the response's success and the value being returned, and it
discards context that can be useful for debugging, such as HTTP responses and caught
exceptions.
"""
fetchval(f::Future) = fetch(f).val

function cap(path::AbstractString, s::AbstractString)
    m = match(Regex("/$path/(\\d+)"), s)
    return m === nothing ? nothing : parse(Snowflake, first(m.captures))
end

include(joinpath("rest", "audit_log.jl"))
include(joinpath("rest", "channel.jl"))
include(joinpath("rest", "emoji.jl"))
include(joinpath("rest", "guild.jl"))
include(joinpath("rest", "invite.jl"))
include(joinpath("rest", "user.jl"))
include(joinpath("rest", "voice.jl"))
include(joinpath("rest", "webhook.jl"))
