module Julicord

export Snowflake,
    Client,
    state,
    add_handler!,
    clear_handlers!

using HTTP
using JSON
using OpenTrick
using WebSockets

# Discord API base.
const DISCORD_API = "https://discordapp.com/api/v6"

# Discord's form of ID.
const Snowflake = Int64
snowflake(s::Union{<:AbstractString, Nothing}) = s === nothing ? nothing : parse(Int64, s)

# Events.

include("events.jl")
using .Events

# Client.

include("client.jl")

end
