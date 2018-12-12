const MESSAGES_REGEX = r"^/channels/\d+/messages/\d+$"
const ENDS_MAJOR_ID_REGEX = r"(?:channels|guilds|webhooks)/\d+$"
const ENDS_ID_REGEX = r"/\d+$"
const EXCEPT_TRAILING_ID_REGEX = r"(.*?)/\d+$"

# A rate limited job queue for one endpoint.
mutable struct JobQueue
    remaining::Nullable{Int}
    reset::Nullable{DateTime}  # UTC.
    jobs::Channel{Function}  # These functions must return an HTTP response.
    retries::Channel{Function}  # Jobs which must be retried (higher priority).

    function JobQueue(limiter)
        q = new(nothing, nothing, Channel{Function}(Inf), Channel{Function}(Inf))

        @async while true
            f = take!(isready(q.retries) ? q.retries : q.jobs)  # Get a job by priority.

            # Wait for any existing rate limits.
            n = now(UTC)
            limiter.reset !== nothing && n < limiter.reset && sleep(limiter.reset - n)
            n = now(UTC)
            q.remaining == 0 && q.reset !== nothing && n < q.reset && sleep(q.reset - n)

            # Run the job, and get the HTTP response.
            r = f()

            if r.status == 429
                # Update the rate limiter with the response body.
                n = now(UTC)
                d = JSON.parse(String(copy(r.body)))
                if get(d, "global", false)
                    limiter.reset = n + Millisecond(get(d, "retry_after", 0))
                end

                # Requeue the job with high priority.
                put!(q.retries, f)
            end

            # Update the rate limiter with the response headers.
            rem = HTTP.header(r, "X-RateLimit-Remaining")
            isempty(rem) || (q.remaining = parse(Int, rem))
            res = HTTP.header(r, "X-RateLimit-Reset")
            isempty(res) || (q.reset = unix2datetime(parse(Int, res)))
        end

        return q
    end
end

# A rate limiter for all endpoints.
mutable struct Limiter
    reset::Nullable{DateTime}  # API-wide limit.
    queues::Dict{String, JobQueue}
    lock::Threads.SpinLock

    function Limiter()
        new(nothing, Dict(), Threads.SpinLock())
    end
end

# Schedule a job.
function enqueue!(f::Function, l::Limiter, method::Symbol, endpoint::AbstractString)
    endpoint = parse_endpoint(endpoint, method)
    locked(l.lock) do
        haskey(l.queues, endpoint) || (l.queues[endpoint] = JobQueue(l))
    end
    put!(l.queues[endpoint].jobs, f)
end

# Get the endpoint which corresponds to its own rate limit.
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
