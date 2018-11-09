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
@boilerplate GuildCreate :docs
GuildCreate(d::Dict{String, Any}) = GuildCreate(Guild(d))

"""
Sent when a [`Guild`](@ref) is updated.
"""
struct GuildUpdate <: AbstractEvent
    guild::Guild
end
@boilerplate GuildUpdate :docs
GuildUpdate(d::Dict{String, Any}) = GuildUpdate(Guild(d))

"""
Sent when a [`Guild`](@ref) is deleted.
"""
struct GuildDelete <: AbstractEvent
    guild::AbstractGuild  # Supposed to be an UnavailableGuild.
end
@boilerplate GuildDelete :docs
GuildDelete(d::Dict{String, Any}) = GuildDelete(AbstractGuild(d))

"""
Sent when a [`User`](@ref) is banned from a [`Guild`](@ref).
"""
struct GuildBanAdd <: AbstractEvent
    guild_id::Snowflake
    user::User
end
@boilerplate GuildBanAdd :dict :docs

"""
Sent when a [`User`](@ref) is unbanned from a [`Guild`](@ref).
"""
struct GuildBanRemove <: AbstractEvent
    guild_id::Snowflake
    user::User
end
@boilerplate GuildBanRemove :dict :docs

"""
Sent when a [`Guild`](@ref) has its [`Emoji`](@ref)s updated.
"""
struct GuildEmojisUpdate <: AbstractEvent
    guild_id::Snowflake
    emojis::Vector{Emoji}
end
@boilerplate GuildEmojisUpdate :dict :docs

"""
Sent when a [`Guild`](@ref) has its [`Integration`](@ref)s updated.
"""
struct GuildIntegrationsUpdate <: AbstractEvent
    guild_id::Snowflake
end
@boilerplate GuildIntegrationsUpdate :dict :docs

"""
Sent when a [`Member`](@ref) is added to a [`Guild`](@ref).
"""
struct GuildMemberAdd <: AbstractEvent
    guild_id::Snowflake
    member::Member
end
@boilerplate GuildMemberAdd :docs
GuildMemberAdd(d::Dict{String, Any}) = GuildMemberAdd(snowflake(d["guild_id"]), Member(d))

"""
Sent when a [`Member`](@ref) is removed from a [`Guild`](@ref).
"""
struct GuildMemberRemove <: AbstractEvent
    guild_id::Snowflake
    user::User
end
@boilerplate GuildMemberRemove :dict :docs

"""
Sent when a [`Member`](@ref) is updated in a [`Guild`](@ref).
"""
struct GuildMemberUpdate <: AbstractEvent
    guild_id::Snowflake
    roles::Vector{Snowflake}
    user::User
    nick::Union{String, Nothing}  # Not supposed to be nullable.
end
@boilerplate GuildMemberUpdate :dict :docs

"""
Sent when the [`Client`](@ref) requests guild members with [`request_guild_members`](@ref).
"""
struct GuildMembersChunk <: AbstractEvent
    guild_id::Snowflake
    members::Vector{Member}
end
@boilerplate GuildMembersChunk :dict :docs

"""
Sent when a new [`Role`](@ref) is created in a [`Guild`](@ref).
"""
struct GuildRoleCreate <: AbstractEvent
    guild_id::Snowflake
    role::Role
end
@boilerplate GuildRoleCreate :dict :docs

"""
Sent when a [`Role`](@ref) is updated in a [`Guild`](@ref).
"""
struct GuildRoleUpdate <: AbstractEvent
    guild_id::Snowflake
    role::Role
end
@boilerplate GuildRoleUpdate :dict :docs

"""
Sent when a [`Role`](@ref) is deleted from a [`Guild`](@ref).
"""
struct GuildRoleDelete <: AbstractEvent
    guild_id::Snowflake
    role_id::Snowflake
end
@boilerplate GuildRoleDelete :dict :docs
