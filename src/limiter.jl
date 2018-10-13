const MESSAGES_REGEX = r"^/channels/\d+/messages/\d+$"

struct Bucket
    limit::Int
    remaining::Int
    reset::DateTime  # UTC.
end

mutable struct Limiter
    reset::Union{DateTime, Nothing}
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
        d = JSON.parse(String(copy(e.response.body)))
        if get(d, "global", false)
            l.reset = now(UTC) + Millisecond(get(d, "retry_after", 0))
            return
        end
    end

    # TODO: Are we supposed to handle missing headers differently?
    headers = Dict(r.headers)
    haskey(headers, "X-RateLimit-Limit") || return
    haskey(headers, "X-RateLimit-Remaining") || return
    haskey(headers, "X-RateLimit-Reset") || return

    limit = parse(Int, headers["X-RateLimit-Limit"])
    remaining = parse(Int, headers["X-RateLimit-Remaining"])
    reset = unix2datetime(parse(Int, headers["X-RateLimit-Reset"]))

    l.buckets[parse_endpoint(endpoint, method)] = Bucket(limit, remaining, reset)
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
    b = get(l.buckets[endpoint], nothing)
    b === nothing && return false

    if n > b.reset
        delete!(l.buckets, endpoint)
        return false
    end

    return b.remaining == 0
end

function parse_endpoint(endpoint::AbstractString; method::Symbol)
    method === :DELETE && match(MESSAGES_REGEX, endpoint) !== nothing &&
        return "$endpoint $method"

    return endpoint  # TODO
end
