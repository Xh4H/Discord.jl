module Julicord

using Dates
using HTTP
using JSON
using OpenTrick
using WebSockets

# Discord API version and base URL.
const API_VERSION = 6
const DISCORD_API = "https://discordapp.com/api/v$API_VERSION"

# Discord's form of ID.
const Snowflake = Int64
function snowflake(s::Union{AbstractString, Nothing, Missing})
    return isa(s, AbstractString) ? parse(Int64, s) : s
end

# Convert a string to a DateTime.
function datetime(s::Union{AbstractString, Nothing, Missing})
    return isa(s, AbstractString) ? DateTime(s[1:end-1], ISODateTimeFormat) : s
end

include("types.jl")
include("events.jl")
using .Events
include("client.jl")

end
