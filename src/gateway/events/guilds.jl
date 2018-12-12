export GuildCreate,
    GuildUpdate,
    GuildDelete,
    GuildBanAdd,
    GuildBanRemove,
    GuildEmojisUpdate,
    GuildIntegrationsUpdate,
    GuildMemberAdd,
    GuildMemberRemove,
    GuildMemberUpdate,
    GuildMembersChunk,
    GuildRoleCreate,
    GuildRoleUpdate,
    GuildRoleDelete

"""
Sent when a new [`Guild`](@ref) is created.
"""
struct GuildCreate <: AbstractEvent
    guild::Guild
end
@boilerplate GuildCreate :docs :mock
GuildCreate(; kwargs...) = GuildCreate(Guild(; kwargs...))
GuildCreate(d::Dict{Symbol, Any}) = GuildCreate(; d...)

"""
Sent when a [`Guild`](@ref) is updated.
"""
struct GuildUpdate <: AbstractEvent
    guild::Guild
end
@boilerplate GuildUpdate :docs :mock
GuildUpdate(; kwargs...) = GuildUpdate(Guild(; kwargs...))
GuildUpdate(d::Dict{Symbol, Any}) = GuildUpdate(; d...)

"""
Sent when a [`Guild`](@ref) is deleted.
"""
struct GuildDelete <: AbstractEvent
    guild::AbstractGuild  # Supposed to be an UnavailableGuild.
end
@boilerplate GuildDelete :docs :mock
GuildDelete(; kwargs...) = GuildDelete(AbstractGuild(; kwargs...))
GuildDelete(d::Dict{Symbol, Any}) = GuildDelete(; d...)

"""
Sent when a [`User`](@ref) is banned from a [`Guild`](@ref).
"""
struct GuildBanAdd <: AbstractEvent
    guild_id::Snowflake
    user::User
end
@boilerplate GuildBanAdd :constructors :docs :mock

"""
Sent when a [`User`](@ref) is unbanned from a [`Guild`](@ref).
"""
struct GuildBanRemove <: AbstractEvent
    guild_id::Snowflake
    user::User
end
@boilerplate GuildBanRemove :constructors :docs :mock

"""
Sent when a [`Guild`](@ref) has its [`Emoji`](@ref)s updated.
"""
struct GuildEmojisUpdate <: AbstractEvent
    guild_id::Snowflake
    emojis::Vector{Emoji}
end
@boilerplate GuildEmojisUpdate :constructors :docs :mock

"""
Sent when a [`Guild`](@ref) has its [`Integration`](@ref)s updated.
"""
struct GuildIntegrationsUpdate <: AbstractEvent
    guild_id::Snowflake
end
@boilerplate GuildIntegrationsUpdate :constructors :docs :mock

"""
Sent when a [`Member`](@ref) is added to a [`Guild`](@ref).
"""
struct GuildMemberAdd <: AbstractEvent
    guild_id::Snowflake
    member::Member
end
@boilerplate GuildMemberAdd :docs :mock
GuildMemberAdd(d::Dict{Symbol, Any}) = GuildMemberAdd(; d...)
function GuildMemberAdd(; kwargs...)
    return GuildMemberAdd(snowflake(kwargs[:guild_id]), Member(; kwargs...))
end

"""
Sent when a [`Member`](@ref) is removed from a [`Guild`](@ref).
"""
struct GuildMemberRemove <: AbstractEvent
    guild_id::Snowflake
    user::User
end
@boilerplate GuildMemberRemove :constructors :docs :mock

"""
Sent when a [`Member`](@ref) is updated in a [`Guild`](@ref).
"""
struct GuildMemberUpdate <: AbstractEvent
    guild_id::Snowflake
    roles::Vector{Snowflake}
    user::User
    nick::Nullable{String}  # Not supposed to be nullable.
end
@boilerplate GuildMemberUpdate :constructors :docs :mock

"""
Sent when the [`Client`](@ref) requests guild members with [`request_guild_members`](@ref).
"""
struct GuildMembersChunk <: AbstractEvent
    guild_id::Snowflake
    members::Vector{Member}
end
@boilerplate GuildMembersChunk :constructors :docs :mock

"""
Sent when a new [`Role`](@ref) is created in a [`Guild`](@ref).
"""
struct GuildRoleCreate <: AbstractEvent
    guild_id::Snowflake
    role::Role
end
@boilerplate GuildRoleCreate :constructors :docs :mock

"""
Sent when a [`Role`](@ref) is updated in a [`Guild`](@ref).
"""
struct GuildRoleUpdate <: AbstractEvent
    guild_id::Snowflake
    role::Role
end
@boilerplate GuildRoleUpdate :constructors :docs :mock

"""
Sent when a [`Role`](@ref) is deleted from a [`Guild`](@ref).
"""
struct GuildRoleDelete <: AbstractEvent
    guild_id::Snowflake
    role_id::Snowflake
end
@boilerplate GuildRoleDelete :constructors :docs :mock
