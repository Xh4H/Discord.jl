module Julicord

using Dates
using Distributed
using HTTP
using JSON
using OpenTrick
using TTLCache
using WebSockets

# Discord API version and base URL.
const API_VERSION = 6
const DISCORD_API = "https://discordapp.com/api/v$API_VERSION"

include("types.jl")
include("events.jl")
include("state.jl")
include("limiter.jl")
include("client.jl")
include("rest.jl")

end
