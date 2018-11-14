export Resumed

"""
Sent when a [`Client`](@ref) resumes its connection.
"""
struct Resumed <: AbstractEvent
    _trace::Vector{String}
end
@boilerplate Resumed :constructors :docs :mock
