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

include(joinpath("types", "types.jl"))
include(joinpath("gateway", "events.jl"))
include(joinpath("client", "client.jl"))
include(joinpath("gateway", "gateway.jl"))
include(joinpath("rest", "rest.jl"))
include(joinpath("utils", "commands.jl"))
include(joinpath("utils", "helpers.jl"))
include("Defaults.jl")

end
