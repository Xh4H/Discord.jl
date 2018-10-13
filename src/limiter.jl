struct Bucket
    limit::Int
    remaining::Int
    reset::DateTime  # UTC.
end

mutable struct Limiter
    reset::Union{DateTime, Nothing}
    # Mapping from endpoint to either the bucket for that endpoint if it is independent of
    # the method, or a mapping from the method to the bucket.
    buckets::Dict{AbstractString, Union{Bucket, Dict{Symbol, Bucket}}}

    Limiter() = new(nothing, Dict())
end

function bucket(l::Limiter, method::Symbol, endpoint::AbstractString)
    endpoint = parse_endpoint(endpoint)
    haskey(l.buckets, endpoint) || return nothing
    v = l.buckets[endpoint]
    return v isa Bucket ? v : get(v, method, nothing)
end

function Base.wait(l::Limiter, method::Symbol, endpoint::AbstractString)
    n = now(UTC)
    if l.reset !== nothing && l.reset > n
        sleep(l.reset - n)
    end

    b = bucket(l, method, endpoint)
    b === nothing && return

    n < b.reset && sleep(b.reset - n)
    delete!(l.buckets, endpoint)
end

function update(
    l::Limiter,
    method::Symbol,
    endpoint::AbstractString,
    r::HTTP.Messages.Response,
)
    headers = Dict(r.headers)
    # TODO: Are we supposed to handle missing headers differently?
    haskey(headers, "X-RateLimit-Limit") || return
    haskey(headers, "X-RateLimit-Remaining") || return
    haskey(headers, "X-RateLimit-Reset") || return
    limit = parse(Int, headers["X-RateLimit-Limit"])
    remaining = parse(Int, headers["X-RateLimit-Remaining"])
    reset = unix2datetime(parse(Int, headers["X-RateLimit-Reset"]))

    b = Bucket(limit, remaining, reset)
    if isspecific(method, endpoint)
        l.buckets[endpoint][method] = b
    else
        l.buckets[endpoint] = b
    end
end

function update(
    l::Limiter,
    method::Symbol,
    endpoint::AbstractString,
    e::HTTP.ExceptionRequest.StatusError,
)
    e.status == 429 || return update(l, method, endpoint, e.response)
    d = JSON.parse(String(copy(e.response.body)))
    if get(d, "global", false)
        l.reset = now(UTC) + Millisecond(get(d, "retry_after", 0))
    else
        update(l, method, endpoint, e.response)
    end
end

# TODO: Inaccuracies in system clock break this, so we can't use this model.
function islimited(l::Limiter, method::Symbol, endpoint::AbstractString)
    n = now(UTC)
    if l.reset !== nothing
        if n < l.reset
            return true
        else
            l.reset = nothing
        end
    end

    endpoint = parse_endpoint(endpoint)
    haskey(l.buckets, endpoint) || return false

    b = bucket(l, method, endpoint)
    b === nothing && return false

    if n > b.reset
        delete!(l.buckets, endpoint)
        return false
    end

    return b.remaining == 0
end

function isspecific(method::Symbol, endpoint::AbstractString)
    return false  # TODO
end

function parse_endpoint(endpoint::AbstractString)
    return endpoint  # TODO
end
