create(::Type{Guild}, c::Client; kwargs...) = create_guild(c; kwargs...)

retrieve(::Type{Guild}, c::Client, guild::Integer) = get_guild(c, guild)
retrieve(::Type{Guild}, c::Client) = get_current_user_guilds(c; kwargs...)

update(c::Client, g::AbstractGuild; kwargs...) = modify_guild(c, g.id; kwargs...)

delete(c::Client, g::AbstractGuild) = delete_guild(c, g.id)
