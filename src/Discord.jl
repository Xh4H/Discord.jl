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

# Shortcuts for common unions.
const Optional{T} = Union{T, Missing}
const Nullable{T} = Union{T, Nothing}
const OptionalNullable{T} = Union{T, Missing, Nothing}
const StringOrChar = Union{AbstractString, AbstractChar}

# Constant functions.
donothing(args...; kwargs...) = nothing
alwaystrue(args...; kwargs...) = true
alwaysfalse(args...; kwargs...) = false

# Run a function with an acquired semaphore.
function withsem(f::Function, s::Base.Semaphore)
    Base.acquire(s)
    try f() finally Base.release(s) end
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
include(joinpath("utils", "helpers.jl"))
include(joinpath("utils", "commands.jl"))
include("Defaults.jl")

end
