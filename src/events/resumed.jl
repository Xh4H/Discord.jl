export Resumed

"""
Sent when a [`Client`](@ref) resumes its connection.
"""
@from_dict struct Resumed <: AbstractEvent
    _trace::Vector{String}
end
