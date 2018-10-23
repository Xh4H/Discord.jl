module Wager

using Dates
using Discord

# Guild ID -> username -> token count.
const TOKENS = Dict{Discord.Snowflake, Dict{String, UInt}}()
const TOKEN_START = 100
const TOKEN_INTERVAL = Minute(30)
const TOKEN_INCREMENT = 100

"""
Add users to the token cache via a `GuildCreate` event.
"""
function add_users(c::Client, e::GuildCreate)
    if !haskey(TOKENS, e.guild.id)
        TOKENS[e.guild.id] = Dict()
    end

    guild = TOKENS[e.guild.id]

    for m in e.guild.members
        if !haskey(guild, m.user.username)
            guild[m.user.username] = TOKEN_START
        end
    end
end

"""
Give out tokens to all users on an interval.
"""
function distribute_tokens(c::Client)
    while isopen(c)
        for g in keys(TOKENS)
            for u in keys(g)
                g[u] += TOKEN_INCREMENT
            end
        end
        sleep(TOKEN_INTERVAL)
    end
end

"""
Insert a guild and/or user from a message into the token cache if they don't exist.
"""
function ensure_updated(m::Discord.Message)
    if !haskey(TOKENS, m.guild_id)
        TOKENS[m.guild_id] = Dict()
    end
    if !haskey(TOKENS[m.guild_id], m.author.username)
        TOKENS[m.guild_id][m.author.username] = TOKEN_START
    end
end

"""
Get the token count for the user who sent a message.
"""
token_count(m::Discord.Message) = get(get(TOKENS, m.guild_id, Dict()), m.author.username, 0)

"""
Reply to a message with the author's token count via a `MessageCreate` event.
"""
function reply_token_count(c::Client, m::Discord.Message)
    ensure_updated(m)
    reply(c, m, "You have $(token_count(m)) tokens.")
end

"""
Reply to a message with the guild's token leaderboard via a `MessageCreate` event.
"""
function reply_token_leaderboard(c::Client, m::Discord.Message)
    ensure_updated(m)

    # Get user => token count pairs by token count in descending order.
    sorted = sort(collect(TOKENS[m.guild_id]); by=p -> p.second, rev=true)

    entries = String[]
    for i in 1:min(10, length(sorted))  # Display at most 10.
        user, tokens = sorted[i]
        push!(entries, "$user: $tokens")
    end

    reply(c, m, join(entries, "\n"))
end

"""
Transfer tokens from one user to another via a `MessageCreate` event.
"""
function send_tokens(c::Client, m::Discord.Message)
    ensure_updated(m)

    words = split(m.content)
    if length(words) < 3
        return reply(c, m, "Invalid !send command.")
    end

    tokens = try
        parse(UInt, words[2])
    catch
        return reply(c, m, "'$(words[2])' is not a valid number of tokens.")
    end
    recipient = words[3]
    if !haskey(TOKENS[m.guild_id], recipient)
        return reply(c, m, "Couldn't find user '$recipient' in this guild.")
    end
    if token_count(m) < tokens
        return reply(c, m, "You don't have enough tokens to give.")
    end

    TOKENS[m.guild_id][m.author.username] -= tokens
    TOKENS[m.guild_id][recipient] += tokens
    reply(c, m, "You sent $tokens tokens to $recipient.")
end

"""
Wager a user's tokens via a `MessageCreate` event. The user either doubles their bet or
loses it.
"""

function wager_tokens(c::Client, m::Discord.Message)
    ensure_updated(m)

    words = split(m.content)
    if length(words) < 2
        return reply(c, m, "Invalid !wager command.")
    end

    tokens = try
        parse(UInt, words[2])
    catch
        return reply(c, m, "'$(words[2])' is not a valid number of tokens.")
    end
    if token_count(m) < tokens
        return reply(c, m, "You don't have enough tokens to wager.")
    end

    if rand() > 0.5
        TOKENS[m.guild_id][m.author.username] += tokens
        reply(c, m, "You win!")
    else
        TOKENS[m.guild_id][m.author.username] -= tokens
        reply(c, m, "You lose.")
    end
end

function main()
    c = Client(ENV["DISCORD_TOKEN"])
    add_handler!(c, GuildCreate, add_users)
    add_command!(c, "!count", reply_token_count)
    add_command!(c, "!leaderboard", reply_token_leaderboard)
    add_command!(c, "!send", send_tokens)
    add_command!(c, "!wager", wager_tokens)
    open(c)
    @async distribute_tokens(c)
    return c
end

end

if abspath(PROGRAM_FILE) == @__FILE__
    c = Wager.main()
    wait(c)
end
