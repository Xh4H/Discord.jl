retrieve(c::Client, ::Type{VoiceRegion}, g::AbstractGuild) = get_guild_voice_regions(c, g.id)
retrieve(c::Client, ::Type{VoiceRegion}) = list_voice_regions(c)
