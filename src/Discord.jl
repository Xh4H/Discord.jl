module Discord

using Dates
using Distributed
using HTTP
using JSON
using OpenTrick
using TimeToLive
using WebSockets

const API_VERSION = 6
const DISCORD_API = "https://discordapp.com/api"

# Generic utils.

function locked(f::Function, l::Threads.AbstractLock)
    lock(l)
    try f() finally unlock(l) end
end

insert_or_update(d, k, v) = d[k] = haskey(d, k) ? merge(d[k], v) : v

include("types.jl")
include("events.jl")
include("state.jl")
include("limiter.jl")
include("client.jl")
include("gateway.jl")
include("rest.jl")
include("commands.jl")
include("Defaults.jl")

end
