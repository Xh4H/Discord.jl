export list_voice_regions

"""
    list_voice_regions(c::Client) -> Vector{VoiceRegion}

Get a list of the [`VoiceRegion`](@ref)s that can be used when creating [`Guild`](@ref)s.
"""
list_voice_regions(c::Client) = Response{Vector{VoiceRegion}}(c, :GET, "/voice/regions")
