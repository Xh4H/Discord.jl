export get_webhooks,
        get_regions,
        get_guild_regions,
        get_vanity_code

# functions

"""
    get_webhooks(c::Client,
        guild::Union{AbstractGuild, Integer}
    ) -> Response{Vector{Webhook}}

Get a list of [`Webhook`](@ref)s.
"""
function get_webhooks(c::Client, guild::Integer)
    return Response{Webhook}(c, :GET, "/guilds/$guild/webhooks")
end

get_webhooks(c::Client, guild::AbstractGuild) = get_webhooks(c, guild.id)

"""
    get_regions(c::Client) -> Response{Vector{VoiceRegion}}

Get a list of [`VoiceRegion`](@ref)s.
"""
function get_regions(c::Client)
    return Response{VoiceRegion}(c, :GET, "/voice/regions")
end

"""
    get_guild_regions(c::Client,
        guild::Union{AbstractGuild, Integer}
    ) -> Response{Vector{VoiceRegion}}

Get a list of [`VoiceRegion`](@ref)s from the given [`AbstractGuild`](@ref).
"""
function get_guild_regions(c::Client, guild::Integer)
    return Response{VoiceRegion}(c, :GET, "/guilds/$guild/regions")
end

get_guild_regions(c::Client, guild::AbstractGuild) = get_guild_regions(c, guild.id)

"""
    get_vanity_code(c::Client
        guild::Union{AbstractGuild, Integer}
    ) -> Response{Invite}

Get the vanity code from the given [`AbstractGuild`](@ref).
"""
function get_vanity_code(c::Client, guild::Integer)
    return Response{Invite}(c, :GET, "/guilds/$guild/vanity-url")
end

get_vanity_code(c::Client, guild::AbstractGuild) = get_vanity_code(c, guild.id)
