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

struct GuildCreate <: AbstractEvent
    guild::AbstractGuild
end

GuildCreate(d::Dict) = GuildCreate(AbstractGuild(d))

struct GuildUpdate <: AbstractEvent
    guild::AbstractGuild
end

GuildUpdate(d::Dict) = GuildUpdate(AbstractGuild(d))

struct GuildDelete <: AbstractEvent
    guild::AbstractGuild
end

GuildDelete(d::Dict) = GuildDelete(AbstractGuild(d))

@from_dict struct GuildBanAdd <: AbstractEvent
    guild_id::Snowflake
    user::User
end

@from_dict struct GuildBanRemove <: AbstractEvent
    guild_id::Snowflake
    user::User
end

@from_dict struct GuildEmojisUpdate <: AbstractEvent
    guild_id::Snowflake
    emojis::Vector{Emoji}
end

@from_dict struct GuildIntegrationsUpdate <: AbstractEvent
    guild_id::Snowflake
end

struct GuildMemberAdd <: AbstractEvent
    guild_id::Snowflake
    member::Member
end

GuildMemberAdd(d::Dict) = GuildMemberAdd(snowflake(d["guild_id"]), Member(d))

struct GuildMemberRemove <: AbstractEvent
    guild_id::Snowflake
    user::User
end

@from_dict struct GuildMemberUpdate <: AbstractEvent
    guild_id::Snowflake
    roles::Vector{Snowflake}
    user::User
    nick::String
end

@from_dict struct GuildMembersChunk <: AbstractEvent
    guild_id::Snowflake
    members::Vector{Member}
end

@from_dict struct GuildRoleCreate <: AbstractEvent
    guild_id::Snowflake
    role::Role
end

@from_dict struct GuildRoleUpdate <: AbstractEvent
    guild_id::Snowflake
    role::Role
end

@from_dict struct GuildRoleDelete <: AbstractEvent
    guild_id::Snowflake
    role_id::Snowflake
end
