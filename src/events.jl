module Events

export AbstractEvent, UnknownEvent

using ..Julicord: Snowflake, snowflake

abstract type AbstractEvent end

struct UnknownEvent <: AbstractEvent
    t::String
    d::Dict{String, Any}
    s::Union{Int, Nothing}

    UnknownEvent(data::Dict) = new(data["t"], data["d"], data["s"])
end

include(joinpath("events", "message_delete.jl"))

const MESSAGE_TYPES = Dict{String, Type{<:AbstractEvent}}(
    "MESSAGE_DELETE" => MessageDelete,
)

function AbstractEvent(data::Dict)
    return if haskey(MESSAGE_TYPES, data["t"])
        MESSAGE_TYPES[data["t"]](data["d"])
    else
        UnknownEvent(data)
    end
end

end
