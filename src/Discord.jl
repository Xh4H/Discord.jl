module Discord

using Dates
using Distributed
using HTTP
using JSON
using OpenTrick
using Setfield
using TimeToLive

const DISCORD_JL_VERSION = v"0.1.0"
const API_VERSION = 6
const DISCORD_API = "https://discordapp.com/api"

const TTLDict = Dict{DataType, Union{Period, Nothing}}

function locked(f::Function, x::Threads.AbstractLock)
    lock(x)
    try f() finally unlock(x) end
end

function catchmsg(e::Exception)
    return sprint(showerror, e) * sprint(Base.show_backtrace, catch_backtrace())
end

include("types/types.jl")
include("gateway/events.jl")
include("client/state.jl")
include("utils/limiter.jl")
include("client/client.jl")
include("gateway/gateway.jl")
include("rest/endpoints/rest.jl")
include("rest/crud/crud.jl")
include("utils/commands.jl")
include("utils/helpers.jl")
include("Defaults.jl")

end
