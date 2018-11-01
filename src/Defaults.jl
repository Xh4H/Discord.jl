module Defaults

export handler

using Discord
using Discord: locked
using TimeToLive

insert_or_update(d, k, v) = d[k] = haskey(d, k) ? merge(d[k], v) : v

function handler(c::Client, e::Ready)
    c.state.v = e.v
    c.state.session_id = e.session_id
    c.state._trace = e._trace
    c.state.user = e.user

    for c in e.private_channels
        insert_or_update(c.state.channels, e.id, c)
    end
    for g in e.guilds
        # Don't merge here because these guilds are unavailable.
        if !haskey(c.state.guilds, g.id)
            c.state.guilds[g.id] = g
        end
    end
end

handler(c::Client, e::Resumed) = c.state._trace = e._trace

function handler(c::Client, e::Union{ChannelCreate, ChannelUpdate})
    if  haskey(c.state.guilds, e.channel.guild_id)
        cs = c.state.guilds[e.channel.guild_id].channels
        idx = findfirst(c -> c.id == e.channel.id, cs)
        if idx === nothing
            push!(cs, e.channel)
        else
            push!(cs, merge(cs[idx], e.channel))
            deleteat!(cs, idx)
        end
    end
    insert_or_update(c.state.channels, e.channel.id, e.channel)
end

handler(c::Client, e::ChannelDelete) = delete!(c.state.channels, e.channel.id)

function handler(c::Client, e::Union{GuildCreate, GuildUpdate})
    if get(c.state.guilds, e.guild.id, nothing) isa Guild
        insert_or_update(c.state.guilds, e.guild.id, e.guild)
    else
        c.state.guilds[e.guild.id] = e.guild
    end
    if !ismissing(e.guild.channels)
        for ch in e.guild.channels
            insert_or_update(c.state.channels, ch.id, ch)
        end
    end

    if !ismissing(e.guild.members)
        if !haskey(c.state.members, e.guild.id)
            c.state.members[e.guild.id] = TTL(c.ttl)
        end
        ms = c.state.members[e.guild.id]
        for m in e.guild.members
            if ismissing(m.user)
                if !haskey(ms, missing)
                    ms[missing] = []
                end
                push!(ms[missing], m)
            else
                insert_or_update(ms, m.user.id, m)
                insert_or_update(c.state.users, m.user.id, m.user)
            end
        end
    end
end

function handler(c::Client, e::GuildDelete)
    delete!(c.state.guilds, e.id)
    delete!(c.state.members, e.id)
    delete!(c.state.presences, e.id)
end

function handler(c::Client, e::GuildEmojisUpdate)
    haskey(c.state.guilds, e.guild_id) || return
    c.state.guilds[e.guild_id] isa Guild || return

    es = c.state.guilds[e.guild_id].emojis
    empty!(es)
    append!(es, e.emojis)
end

function handler(c::Client, e::GuildMemberAdd)
    if !haskey(c.state.members, e.guild_id)
        c.state.members[e.guild_id] = TTL(c.ttl)
    end
    ms = c.state.members[e.guild_id]
    if ismissing(e.member.user)
        if !haskey(ms, missing)
            ms[missing] = []
        end
        touch(ms, missing)
        push!(ms[missing], e.member)
    else
        ms[e.member.user.id] = e.member
        insert_or_update(c.state.users, e.member.user.id, e.member.user)
    end
end

function handler(c::Client, e::GuildMemberUpdate)
    haskey(c.state.members, e.guild_id) || return
    haskey(c.state.members[e.guild_id], e.user.id) || return

    ms = c.state.members[e.guild_id]
    m = ms[e.user.id]
    ms[e.user.id] = Member(
        e.user,
        e.nick,
        e.roles,
        m.joined_at,
        m.deaf,
        m.mute,
    )
    insert_or_update(c.state.users, e.user.id, e.user)
end

function handler(c::Client, e::GuildMemberRemove)
    haskey(c.state.members, e.guild_id) || return
    delete!(c.state.members[e.guild_id], e.user.id)
end

function handler(c::Client, e::GuildMembersChunk)
    if !haskey(c.state.members, e.guild_id)
        c.state.members[e.guild_id] = TTL(c.ttl)
    end

    ms = c.state.members[e.guild_id]

    for m in e.members
        if ismissing(m.user)
            if !haskey(ms, missing)
                ms[missing] = []
            end

            touch(ms, missing)
            push!(ms[missing], m)
        else
            insert_or_update(ms, m.user.id, m)
            insert_or_update(c.state.users, m.user.id, m.user)
        end
    end
end

function handler(c::Client, e::GuildRoleCreate)
    haskey(c.state.guilds, e.guild_id) || return
    isa(c.state.guilds[e.guild_id], Guild) || return
    push!(c.state.guilds[e.guild_id].roles, e.role)
end

function handler(c::Client, e::GuildRoleUpdate)
    haskey(c.state.guilds, e.guild_id) || return
    isa(c.state.guilds[e.guild_id], Guild) || return

    rs = c.state.guilds[e.guild_id].roles
    idx = findfirst(r -> r.id == e.role.id, rs)
    role = if idx !== nothing
        r = merge(rs[idx], e.role)
        deleteat!(rs, idx)
        r
    else
        e.role
    end
    push!(rs, role)
end

function handler(c::Client, e::GuildRoleDelete)
    haskey(c.state.guilds, e.guild_id) || return
    isa(c.state.guilds[e.guild_id], Guild) || return

    rs = c.state.guilds[e.guild_id].roles
    idx = findfirst(r -> r.id == e.role_id, rs)
    idx === nothing || deleteat!(rs, idx)
end

function handler(c::Client, e::Union{MessageCreate, MessageUpdate})
    insert_or_update(c.state.messages, e.message.id, e.message)
end

handler(c::Client, e::MessageDelete) = delete!(c.state.messages, e.id)

function handler(c::Client, e::MessageDeleteBulk)
    for id in e.ids
        delete!(c.state.messages, id)
    end
end

function handler(c::Client, e::PresenceUpdate)
    if !haskey(c.state.presences, e.presence.guild_id)
        c.state.presences[e.presence.guild_id] = TTL(c.ttl)
    end
    insert_or_update(c.state.presences[e.presence.guild_id], e.presence.user.id, e.presence)
end

function handler(c::Client, e::MessageReactionAdd)
    haskey(c.state.messages, e.message_id) || return

    locked(c.state.lock) do
        touch(c.state.messages, e.message_id)
        m = c.state.messages[e.message_id]
        if ismissing(m.reactions)
            m.reactions = [Reaction(1, e.user_id == c.state.user.id, e.emoji)]
        else
            idx = findfirst(r -> r.emoji.name == e.emoji.name, m.reactions)
            if idx === nothing
                push!(m.reactions, Reaction(1, e.user_id == c.state.user.id, e.emoji))
            else
                m.reactions[idx].count += 1
                m.reactions[idx].me |= e.user_id == c.state.user.id
            end
        end
    end
end

function handler(c::Client, e::MessageReactionRemove)
    haskey(c.state.messages, e.message_id) || return
    ismissing(c.state.messages[e.message_id].reactions) && return

    locked(c.state.lock) do
        touch(c.state.messages, e.message_id)
        rs = c.state.messages[e.message_id].reactions
        idx = findfirst(r -> r.emoji.name == e.emoji.name, rs)
        if idx !== nothing
            if rs[idx].count == 1
                deleteat!(rs, idx)
            else
                rs[idx].count -= 1
                rs[idx].me &= e.user_id != c.state.user.id
            end
        end
    end
end

function handler(c::Client, e::MessageReactionRemoveAll)
    haskey(c.state.messages, e.message_id) || return
    ismissing(c.state.messages[e.message_id].reactions) && return

    locked(c.state.lock) do
        touch(c.state.messages, e.message_id)
        empty!(c.state.messages[e.message_id].reactions)
    end
end

end
