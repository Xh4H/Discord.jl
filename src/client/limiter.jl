const MESSAGES_REGEX = r"^/channels/\d+/messages/\d+$"
const ENDS_MAJOR_ID_REGEX = r"(?:channels|guilds|webhooks)/\d+$"
const ENDS_ID_REGEX = r"/\d+$"
const EXCEPT_TRAILING_ID_REGEX = r"(.*?)/\d+$"

mutable struct Bucket <: Threads.AbstractLock
    remaining::Union{Int, Nothing}
    reset::Union{DateTime, Nothing}  # UTC.
    sem::Base.Semaphore

    Bucket() = new(nothing, nothing, Base.Semaphore(1))
    Bucket(remaining::Int, reset::DateTime) = new(remaining, reset, Base.Semaphore(1))
end

mutable struct Limiter
    reset::Union{DateTime, Nothing}  # API-wide limit.
    buckets::Dict{AbstractString, Bucket}
    lock::Threads.AbstractLock

    Limiter() = new(nothing, Dict(), Threads.SpinLock())
end

function Bucket(l::Limiter, method::Symbol, endpoint::AbstractString)
    locked(l.lock) do
        endpoint = parse_endpoint(endpoint, method)
        if !haskey(l.buckets, endpoint)
            l.buckets[endpoint] = Bucket()
        end
        return l.buckets[endpoint]
    end
end

Base.lock(b::Bucket) = Base.acquire(b.sem)
Base.unlock(b::Bucket) = Base.release(b.sem)

function reset!(b::Bucket)
    b.remaining = nothing
    b.reset = nothing
end

# Note: These DateTime operations only work if your system clock is accurate.

function Base.wait(l::Limiter, b::Bucket)
    n = now(UTC)
    if l.reset !== nothing && l.reset > n
        sleep(l.reset - n)
    end

    if b.reset !== nothing && n < b.reset
        sleep(b.reset - n)
        reset!(b)
    end
end

function update!(l::Limiter, b::Bucket, r::HTTP.Messages.Response)
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

    b.remaining = parse(Int, headers["X-RateLimit-Remaining"])
    b.reset = unix2datetime(parse(Int, headers["X-RateLimit-Reset"]))
end

function islimited(l::Limiter, b::Bucket)
    n = now(UTC)

    if l.reset !== nothing
        if n < l.reset
            return true
        else
            l.reset = nothing
        end
    end

    (b.remaining === nothing || b.reset === nothing) && return false
    if n > b.reset
        reset!(b)
        return false
    end

    return b.remaining == 0
end

function parse_endpoint(endpoint::AbstractString, method::Symbol)
    return if method === :DELETE && match(MESSAGES_REGEX, endpoint) !== nothing
        # Special case 1: Deleting messages has its own rate limit.
        first(match(EXCEPT_TRAILING_ID_REGEX, endpoint).captures) * " $method"
    elseif startswith(endpoint, "/invites/")
        # Special case 2: Invites are identified by a non-numeric code.
        "/invites"
    elseif match(ENDS_MAJOR_ID_REGEX, endpoint) !== nothing
        endpoint
    elseif match(ENDS_ID_REGEX, endpoint) !== nothing
        first(match(EXCEPT_TRAILING_ID_REGEX, endpoint).captures)
    else
        endpoint
    end
end
