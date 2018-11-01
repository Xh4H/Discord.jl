function create(::Type{Integration}, c::Client, g::AbstractGuild; kwargs...)
    return create_guild_integration(c, g.id; kwargs...)
end

retrieve(::Type{Integration}, c::Client, g::AbstractGuild) = get_guild_integrations(c, g.id)

function update(c::Client, i::Integration, g::AbstractGuild; kwargs...)
    return modify_guild_integration(c, g.id, i.id; kwargs...)
end

function delete(c::Client, i::Integration, g::AbstractGuild)
    return delete_guild_integration(c, g.id, i.id)
end
