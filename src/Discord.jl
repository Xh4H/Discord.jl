module Discord

using Dates
using Distributed
using HTTP
using InteractiveUtils
using JSON
using OpenTrick
using Setfield
using TimeToLive

const DISCORD_JL_VERSION = v"0.1.0"
const API_VERSION = 6
const DISCORD_API = "https://discordapp.com/api"

const TTLDict = Dict{DataType, Union{Period, Nothing}}

# Run a function with a locked lock.
function locked(f::Function, x::Threads.AbstractLock)
    lock(x)
    try f() finally unlock(x) end
end

# Format a caught exception.
function catchmsg(e::Exception)
    return sprint(showerror, e) * sprint(Base.show_backtrace, catch_backtrace())
end

# Precompile all methods of a function, running it if force is set.
function compile(f::Function, force::Bool; kwargs...)
    for m in methods(f)
        types = Tuple(m.sig.types[2:end])
        precompile(f, types)
        force && try f(mock.(types; kwargs...)...) catch end
    end
end

include(joinpath("types", "types.jl"))
include(joinpath("gateway", "events", "events.jl"))
include(joinpath("client", "client.jl"))
include(joinpath("gateway", "gateway.jl"))
include(joinpath("rest", "rest.jl"))
include(joinpath("utils", "commands.jl"))
include(joinpath("utils", "helpers.jl"))
include("Defaults.jl")

end
