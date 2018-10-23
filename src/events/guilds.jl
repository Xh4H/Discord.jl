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

GuildCreate(d::Dict{String, Any}) = GuildCreate(Guild(d))

JSON.lower(gc::GuildCreate) = JSON.lower(gc.guild)

"""
Sent when a [`Guild`](@ref) is updated.
"""
struct GuildUpdate <: AbstractEvent
    guild::Guild
end

JSON.lower(gu::GuildUpdate) = JSON.lower(gu.guild)

GuildUpdate(d::Dict{String, Any}) = GuildUpdate(Guild(d))

"""
Sent when a guild is deleted, and contains an [`UnavailableGuild`](@ref).
"""
struct GuildDelete <: AbstractEvent
    guild::UnavailableGuild
end

GuildDelete(d::Dict{String, Any}) = GuildDelete(UnavailableGuild(d))

JSON.lower(gd::GuildDelete) = JSON.lower(gd.guild)

"""
Sent when a [`User`](@ref) is banned from a [`Guild`](@ref).
"""
@from_dict struct GuildBanAdd <: AbstractEvent
    guild_id::Snowflake
    user::User
end

"""
Sent when a [`User`](@ref) is unbanned from a [`Guild`](@ref).
"""
@from_dict struct GuildBanRemove <: AbstractEvent
    guild_id::Snowflake
    user::User
end

"""
Sent when a [`Guild`](@ref) has its [`Emoji`](@ref)s updated.
"""
@from_dict struct GuildEmojisUpdate <: AbstractEvent
    guild_id::Snowflake
    emojis::Vector{Emoji}
end

"""
Sent when a [`Guild`](@ref) has its [`Integration`](@ref)s updated.
"""
@from_dict struct GuildIntegrationsUpdate <: AbstractEvent
    guild_id::Snowflake
end

"""
Sent when a [`Member`](@ref) is added to a [`Guild`](@ref).
"""
struct GuildMemberAdd <: AbstractEvent
    guild_id::Snowflake
    member::Member
end

GuildMemberAdd(d::Dict{String, Any}) = GuildMemberAdd(snowflake(d["guild_id"]), Member(d))

function JSON.lower(gma::GuildMemberAdd)
    d = JSON.lower(gma.member)
    d["guild_id"] = gma.guild_id
    return d
end

"""
Sent when a [`Member`](@ref) is removed from a [`Guild`](@ref).
"""
@from_dict struct GuildMemberRemove <: AbstractEvent
    guild_id::Snowflake
    user::User
end

"""
Sent when a [`Member`](@ref) is updated in a [`Guild`](@ref).
"""
@from_dict struct GuildMemberUpdate <: AbstractEvent
    guild_id::Snowflake
    roles::Vector{Snowflake}
    user::User
    nick::Union{String, Nothing}  # Not supposed to be nullable.
end

"""
Sent when the [`Client`](@ref) requests guild members with [`request_guild_members`](@ref).
"""
@from_dict struct GuildMembersChunk <: AbstractEvent
    guild_id::Snowflake
    members::Vector{Member}
end

"""
Sent when a new [`Role`](@ref) is created in a [`Guild`](@ref).
"""
@from_dict struct GuildRoleCreate <: AbstractEvent
    guild_id::Snowflake
    role::Role
end

"""
Sent when a [`Role`](@ref) is updated in a [`Guild`](@ref).
"""
@from_dict struct GuildRoleUpdate <: AbstractEvent
    guild_id::Snowflake
    role::Role
end

"""
Sent when a [`Role`](@ref) is deleted from a [`Guild`](@ref).
"""
@from_dict struct GuildRoleDelete <: AbstractEvent
    guild_id::Snowflake
    role_id::Snowflake
end
