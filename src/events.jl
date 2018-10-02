module Events

export AbstractEvent,
    UnknownEvent,
    MessageDelete

import ..Julicord: Snowflake, snowflake

abstract type AbstractEvent end

struct UnknownEvent <: AbstractEvent
    t::String
    d::Dict{String, Any}
    s::Union{Int, Nothing}
end

function Base.convert(::Type{UnknownEvent}, data::Dict)
    return UnknownEvent(
        data["t"],
        data["d"],
        data["s"],
    )
end

include(joinpath("events", "message_delete.jl"))

const MESSAGE_TYPES = Dict{String, Type{<:AbstractEvent}}(
    "MESSAGE_DELETE" => MessageDelete,
)

function Base.convert(::Type{AbstractEvent}, data::Dict)
    return if haskey(MESSAGE_TYPES, data["t"])
        convert(MESSAGE_TYPES[data["t"]], data["d"])
    else
        convert(UnknownEvent, data)
    end
end

end
