module Julicord

export Snowflake,
    Client,
    user,
    state,
    add_handler!,
    clear_handlers!

using HTTP
using JSON
using OpenTrick
using WebSockets

# Discord API version and base URL.
const API_VERSION = 6
const DISCORD_API = "https://discordapp.com/api/v$API_VERSION"

# Discord's form of ID.
const Snowflake = Int64
snowflake(s::Union{<:AbstractString, Nothing}) = s === nothing ? nothing : parse(Int64, s)

# Events.

include("events.jl")
using .Events

# Client.

include("client.jl")

end
