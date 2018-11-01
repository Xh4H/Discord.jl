function retrieve(::Type{VoiceRegion}, c::Client, g::AbstractGuild)
    return get_guild_voice_regions(c, g.id)
end
retrieve(::Type{VoiceRegion}, c::Client) = list_voice_regions(c)
