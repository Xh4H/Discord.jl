module Events

export AbstractEvent,
    MessageDelete

import ..Julicord: Snowflake, snowflake

abstract type AbstractEvent end

include(joinpath("events", "message_delete.jl"))

const MESSAGE_TYPES = Dict{String, Type{<:AbstractEvent}}(
    "MESSAGE_DELETE" => MessageDelete,
)

Base.convert(::Type{AbstractEvent}, data::Dict) = convert(MESSAGE_TYPES[data["t"]], data["d"])

end
