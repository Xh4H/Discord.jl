module Wager

using Dates
using Discord

# TODO: Users are not properly hashable (or TimeToLive haskey is broken).
const TOKENS = Dict{Discord.Snowflake, Dict{Discord.User, UInt}}()
const TOKEN_START = 100
const TOKEN_INTERVAL = Minute(30)
const TOKEN_INCREMENT = 100

# Runs every time the client receives a GuildCreate event to add users.
function handle_guild_create(c::Client, e::GuildCreate)
    if !haskey(TOKENS, e.guild.id)
        TOKENS[e.guild.id] = Dict()
    end

    guild = TOKENS[e.guild.id]

    for m in e.guild.members
        if !haskey(guild, m.user)
            guild[m.user] = TOKEN_START
        end
    end
end

# Gives out tokens to all users on an interval.
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

# Inserts guilds or users if necessary.
function ensure_updated(m::Discord.Message)
    if !haskey(TOKENS, m.guild_id)
        TOKENS[m.guild_id] = Dict()
    end
    if !haskey(TOKENS[m.guild_id], m.author)
        TOKENS[m.guild_id][m.author] = TOKEN_START
    end
end

# Gets the token count for a user.
token_count(m::Discord.Message) = get(get(TOKENS, m.guild_id, Dict()), m.author, 0)

# Replies to a message with the author's token count.
function reply_token_count(c::Client, m::Discord.Message)
    ensure_updated(m)
    reply(c, m, "You have $(token_count(m)) tokens.")
end

# Replies to a message with the guild's leaderboard.
function reply_token_leaderboard(c::Client, m::Discord.Message)
    ensure_updated(m)

    # Get user => token count pairs by token count in descending order.
    sorted = sort(collect(TOKENS[m.guild_id]); by=p -> p.second, rev=true)

    entries = String[]
    for i in 1:min(10, length(sorted))  # Display at most 10.
        user, tokens = sorted[i]
        push!(entries, "$(user.username): $tokens")
    end

    reply(c, m, join(entries, "\n"))
end

# Transfers tokens from one user to another.
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
    recipient = findfirst(u -> u.username == words[3], keys(TOKENS[m.guild_id]))

    if recipient === nothing
        return reply(c, m, "Coulnd't find user '$(words[3])' in this guild.")
    end
    if token_count(m) < tokens
        return reply(c, m, "You don't have enough tokens to give.")
    end

    TOKENS[m.guild_id][m.author] -= tokens
    TOKENS[m.guild_id][recipient] += tokens
    reply(c, m, "You sent $tokens tokens to $(recipient.username).")
end

# Wagers some tokens. The user either doubles their bet or loses it.
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
        return reply(c, m, "You don't have enough tokens to give.")
    end

    if rand() > 0.5
        TOKENS[m.guild_id][m.author] += tokens
        reply(c, m, "You win!")
    else
        TOKENS[m.guild_id][m.author] -= tokens
        reply(c, m, "You lose.")
    end
end

function main()
    c = Client(ENV["DISCORD_TOKEN"])
    add_handler!(c, GuildCreate, handle_guild_create)
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
