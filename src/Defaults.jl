module Defaults

export handler_cached

using Discord
using Discord: INFO, locked, logmsg
using Setfield

function handler(c::Client, e::Ready)
    logmsg(c, INFO, "Logged in as $(e.user.username)")

    c.state.v = e.v
    c.state.session_id = e.session_id
    c.state._trace = e._trace
    c.state.user = e.user

    for ch in e.private_channels
        put!(c.state, ch)
    end
    for g in e.guilds
        # Don't use put! normally here because these guilds are unavailable.
        if !haskey(c.state.guilds, g.id)
            c.state.guilds[g.id] = g
        end
    end
end

handler(c::Client, e::Resumed) = c.state._trace = e._trace
handler(c::Client, e::Union{ChannelCreate, ChannelUpdate}) = put!(c.state, e.channel)
handler(c::Client, e::Union{GuildCreate, GuildUpdate}) = put!(c.state, e.guild)
handler(c::Client, e::GuildEmojisUpdate) = put!(c.state, e.emojis; guild=e.guild_id)
handler(c::Client, e::GuildMemberAdd) = put!(c.state, e.member; guild=e.guild_id)
handler(c::Client, e::GuildMembersChunk) = put!(c.state, e.members; guild=e.guild_id)
handler(c::Client, e::Union{MessageCreate, MessageUpdate}) = put!(c.state, e.message)
handler(c::Client, e::PresenceUpdate) = put!(c.state, e.presence)

function handler(c::Client, e::ChannelPinsUpdate)
    haskey(c.state.channels, e.channel_id) || return
    ch = c.state.channels[e.channel_id]
    if !ismissing(e.last_pin_timestamp)
        c.state.channels[ch.id] = @set ch.last_pin_timestamp =  e.last_pin_timestamp
    end
end

function handler(c::Client, e::Union{GuildIntegrationsUpdate, GuildBanRemove})
    touch(c.state.guilds, e.guild_id)
end

function handler(c::Client, e::UserUpdate)
    put!(c.state, e.user)

    for ms in values(c.state.members)
        if haskey(ms, e.user.id)
            m = ms[e.user.id]
            ms[e.user.id] = @set m.user = merge(m.user, e.user)
        end
    end

    for g in values(c.state.guilds)
        if g isa Guild && !ismissing(g.members)
            ms = g.members
            idx = findfirst(m -> m.user.id == e.user.id, ms)
            if idx !== nothing
                m = ms[idx]
                ms[idx] = @set m.user = merge(m.user, e.user)
            end
        end
    end
end

function handler(c::Client, e::MessageDelete)
    delete!(c.state.messages, e.id)
    touch(c.state.channels, e.channel_id)
    touch(c.state.guilds, e.guild_id)
end

function handler(c::Client, e::ChannelDelete)
    channel = e.channel.id
    delete!(c.state.channels, channel)

    if !ismissing(e.channel.guild_id) && haskey(c.state.guilds, e.channel.guild_id)
        g = c.state.guilds[e.channel.guild_id]
        chs = g.channels
        ismissing(chs) && return
        idx = findfirst(ch -> ch.id == channel, chs)
        idx === nothing || deleteat!(chs, idx)
    end
end

function handler(c::Client, e::GuildDelete)
    delete!(c.state.guilds, e.guild.id)
    delete!(c.state.members, e.guild.id)
    delete!(c.state.presences, e.guild.id)

    if e.guild isa Guild && !ismissing(e.guild.channels)
        for channel in map(ch -> ch.id, e.guild.channels)
            delete!(c.state.channels, channel)
        end
    end
end

function handler(c::Client, e::GuildMemberUpdate)
    if haskey(c.state.guilds, e.guild_id)
        g = c.state.guilds[e.guild_id]
        if g isa Guild && !ismissing(g.members)
            idx = findfirst(m -> !ismissing(m.user) && m.user.id == e.user.id, g.members)
            if idx !== nothing
                m = g.members[idx]
                m = @set m.roles = e.roles
                m = @set m.user = merge(m.user, e.user)
                m = @set m.nick = e.nick
                g.members[idx] = m
            end
        end
    end

    haskey(c.state.members, e.guild_id) || return
    haskey(c.state.members[e.guild_id], e.user.id) || return

    ms = c.state.members[e.guild_id]
    m = ms[e.user.id]
    m = @set m.user = merge(m.user, e.user)
    m = @set m.nick = e.nick
    m = @set m.roles = e.roles
    ms[e.user.id] = m

    put!(c.state, e.user)
end

function handler(c::Client, e::GuildMemberRemove)
    ismissing(e.user) && return
    haskey(c.state.members, e.guild_id) || return
    delete!(c.state.members[e.guild_id], e.user.id)

    haskey(c.state.guilds, e.guild_id) || return
    ms = c.state.guilds[e.guild_id].members
    idx = findfirst(m -> !ismissing(m.user) && m.user.id == e.user.id, ms)
    idx === nothing || deleteat!(ms, idx)
end

function handler(c::Client, e::Union{GuildRoleCreate, GuildRoleUpdate})
    put!(c.state, e.role; guild=e.guild_id)
end

function handler(c::Client, e::GuildRoleDelete)
    haskey(c.state.guilds, e.guild_id) || return
    isa(c.state.guilds[e.guild_id], Guild) || return
    rs = c.state.guilds[e.guild_id].roles
    ismissing(rs) && return

    idx = findfirst(r -> r.id == e.role_id, rs)
    idx === nothing || deleteat!(rs, idx)
end

function handler(c::Client, e::MessageDeleteBulk)
    for id in e.ids
        delete!(c.state.messages, id)
    end

    touch(c.state.channels, e.channel_id)
    touch(c.state.channels, e.guild_id)
end

function handler(c::Client, e::MessageReactionAdd)
    put!(c.state, e.emoji; message=e.message_id, user=e.user_id)

    touch(c.state.channels, e.channel_id)
    touch(c.state.guilds, e.guild_id)
    touch(c.state.users, e.user_id)
    haskey(c.state.members, e.guild_id) && touch(c.state.members[e.guild_id], e.user_id)
end

function handler(c::Client, e::MessageReactionRemove)
    locked(c.state.lock) do
        haskey(c.state.messages, e.message_id) || return
        ismissing(c.state.messages[e.message_id].reactions) && return

        rs = c.state.messages[e.message_id].reactions
        idx = findfirst(r -> r.emoji.name == e.emoji.name, rs)
        if idx !== nothing
            if rs[idx].count == 1
                deleteat!(rs, idx)
            else
                r = rs[idx]
                r = @set r.count -= 1
                r = @set r.me = r.me & ismissing(c.state.user) || c.state.user.id != e.user_id  # TODO: &= (Setfield#55).
                rs[idx] = r
            end
        end
    end

    touch(c.state.channels, e.channel_id)
    touch(c.state.guilds, e.guild_id)
    touch(c.state.users, e.user_id)
    haskey(c.state.members, e.guild_id) && touch(c.state.members[e.guild_id], e.user_id)
end

function handler(c::Client, e::MessageReactionRemoveAll)
    haskey(c.state.messages, e.message_id) || return
    ismissing(c.state.messages[e.message_id].reactions) && return

    locked(c.state.lock) do
        empty!(c.state.messages[e.message_id].reactions)
    end

    touch(c.state.channels, e.channel_id)
    touch(c.state.guilds, e.guild_id)
end

function handler(c::Client, e::GuildBanAdd)
    if haskey(c.state.members, e.guild_id)
        delete!(c.state.members[e.guild_id], e.user.id)
    end

    if haskey(c.state.guilds, e.guild_id)
        ms = c.state.guilds[e.guild_id].members
        ismissing(ms) && return
        idx = findfirst(m -> !ismissing(m.user) && m.user.id == e.user.id, ms)
        idx === nothing || deleteat!(ms, idx)
    end
end

for T in map(m -> m.sig.types[3], methods(handler).ms)
    @eval handler_cached(c::Client, e::$T) = c.use_cache && handler(c, e)
end

end
