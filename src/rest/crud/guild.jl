create(c::Client, ::Type{Guild}; kwargs...) = create_guild(c; kwargs...)

retrieve(c::Client, ::Type{Guild}, guild::Integer) = get_guild(c, guild)
retrieve(c::Client, ::Type{Guild}; kwargs...) = get_current_user_guilds(c; kwargs...)

update(c::Client, g::AbstractGuild; kwargs...) = modify_guild(c, g.id; kwargs...)

delete(c::Client, g::AbstractGuild) = delete_guild(c, g.id)
