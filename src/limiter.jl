const MESSAGES_REGEX = r"^/channels/\d+/messages/\d+$"
const ENDS_MAJOR_ID_REGEX = r"(?:channels|guilds|webhooks)/\d+$"
const ENDS_ID_REGEX = r"/\d+$"
const EXCEPT_TRAILING_ID_REGEX = r"(.*?)/\d+$"

struct Bucket
    remaining::Int
    reset::DateTime  # UTC.
end

mutable struct Limiter
    reset::Union{DateTime, Nothing}  # The global limit.
    buckets::Dict{AbstractString, Bucket}

    Limiter() = new(nothing, Dict())
end

# Note: These DateTime operations only work if your system clock is accurate.

function Base.wait(l::Limiter, method::Symbol, endpoint::AbstractString)
    n = now(UTC)
    if l.reset !== nothing && l.reset > n
        sleep(l.reset - n)
    end

    endpoint = parse_endpoint(endpoint)
    b = get(l.buckets, endpoint, nothing)

    if b !== nothing
        n < b.reset && sleep(b.reset - n)
        delete!(l.buckets, endpoint)
    end
end

function update(
    l::Limiter,
    method::Symbol,
    endpoint::AbstractString,
    r::HTTP.Messages.Response,
)
    if r.status == 429
        d = JSON.parse(String(copy(r.body)))
        if get(d, "global", false)
            l.reset = now(UTC) + Millisecond(get(d, "retry_after", 0))
            return
        end
    end

    headers = Dict(r.headers)
    haskey(headers, "X-RateLimit-Remaining") || return
    haskey(headers, "X-RateLimit-Reset") || return
    remaining = parse(Int, headers["X-RateLimit-Remaining"])
    reset = unix2datetime(parse(Int, headers["X-RateLimit-Reset"]))

    l.buckets[parse_endpoint(endpoint, method)] = Bucket(remaining, reset)
end

function islimited(l::Limiter, method::Symbol, endpoint::AbstractString)
    n = now(UTC)
    if l.reset !== nothing
        if n < l.reset
            return true
        else
            l.reset = nothing
        end
    end

    endpoint = parse_endpoint(endpoint, method)
    haskey(l.buckets, endpoint) || return false
    b = l.buckets[endpoint]

    if n > b.reset
        delete!(l.buckets, endpoint)
        return false
    end

    return b.remaining == 0
end

function parse_endpoint(endpoint::AbstractString, method::Symbol)
    return if method === :DELETE && match(MESSAGES_REGEX, endpoint) !== nothing
        first(match(EXCEPT_TRAILING_ID_REGEX, endpoint).captures) * " $method"
    elseif match(ENDS_MAJOR_ID_REGEX, endpoint) !== nothing
        endpoint
    elseif match(ENDS_ID_REGEX, endpoint) !== nothing
        first(match(EXCEPT_TRAILING_ID_REGEX, endpoint).captures)
    else
        endpoint
    end
end
