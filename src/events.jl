export AbstractEvent, UnknownEvent

abstract type AbstractEvent end

"""
An unknown event.
"""
struct UnknownEvent <: AbstractEvent
    t::String
    d::Dict{String, Any}
    s::Union{Int, Nothing}
end

UnknownEvent(data::Dict) = UnknownEvent(data["t"], data["d"], data["s"])

include(joinpath("events", "message_delete.jl"))

const EVENT_TYPES = Dict{String, Type{<:AbstractEvent}}(
    "MESSAGE_DELETE" => MessageDelete,
)

function AbstractEvent(data::Dict)
    return if haskey(EVENT_TYPES, data["t"])
        EVENT_TYPES[data["t"]](data["d"])
    else
        UnknownEvent(data)
    end
end
