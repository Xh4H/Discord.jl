function retrieve(c::Client, ::Type{VoiceRegion}, g::AbstractGuild)
    return get_guild_voice_regions(c, g.id)
end
retrieve(c::Client, ::Type{VoiceRegion}) = list_voice_regions(c)
