module Discord

using Dates
using Distributed
using HTTP
using JSON
using OpenTrick
using Setfield
using TimeToLive

const API_VERSION = 6
const DISCORD_API = "https://discordapp.com/api"

function locked(f::Function, l::Threads.AbstractLock)
    lock(l)
    try f() finally unlock(l) end
end

function catchmsg(e::Exception)
    return sprint(showerror, e) * sprint(Base.show_backtrace, catch_backtrace())
end

include("types.jl")
include("events.jl")
include("state.jl")
include("limiter.jl")
include("client.jl")
include("gateway.jl")
include("rest.jl")
include("crud.jl")
include("commands.jl")
include("helpers.jl")
include("Defaults.jl")

end
