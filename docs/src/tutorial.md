```@meta
CurrentModule = Discord
```

# Tutorial

*The completed code can be found in [`wager.jl`](https://github.com/PurgePJ/Discord.jl/blob/master/examples/wager.jl).*

In this tutorial, we're going to build a basic currency/wager bot with Discord.jl.
The bot will give users the following capabilities:

* Receive tokens from the bot on a regular interval
* See their current token count
* See a leaderboard of the top earners in the guild
* Give tokens to other users by username
* Wager tokens on a coin flip

A couple of rules apply:

* Users cannot wager or give more tokens than they currently have (this means that users cannot go into debt)
* Users cannot give tokens to users in a different guild

Let's get started! First of all, we need to import Discord.jl, and we'll also start a `main` function which we'll add to as we go along.

```julia
using Discord

function main()
    c = Client(ENV["DISCORD_TOKEN"])
    # To be continued...
end
```

Next, let's think about how we want to maintain the state of our application.
According to the requirements and rules outlined above, we need to track users and their token count, which is nonnegative, by guild.
Therefore, our internal state representation is going to be a mapping from guild IDs to mappings from users to token counts via a `Dict{Discord.Snowflake, Dict{Discord.User, UInt}}`.
In this example, we aren't particularly concerned with persistent storage so we'll just keep everything in memory.

```julia
const USER_TOKENS = Dict{Discord.Snowflake, Dict{Discord.Snowflake, UInt}}()
```

Now, since this `Dict` starts off empty, how are we going to populate it with users?
We can do this by defining a handler on [`GuildCreate`](@ref), whose `guild` field contains its own ID, as well as a list of [`Member`](@ref)s, each of which contains a [`User`](@ref).

```julia
# Runs every time the client receives a GuildCreate event to add users.
function handle_guild_create(c::Client, e::GuildCreate)
    if !haskey(TOKENS, e.guild.id)
        TOKENS[e.guild_id] = Dict()
    end

    guild = TOKENS[e.guild.id]

    for m in e.guild.members
        if !haskey(guild, m.user.id)
            guild[m.user.id] = 0
        end
    end
end
```

Let's add that handler to our [`Client`](@ref), and connect to the gateway with [`open`](@ref):

```julia
function main()
    # ...
    add_handler!(c, GuildCreate, handle_guild_create)
    open(c)
end
```

With that taken care of, we can start distributing tokens.
First, we need to decide how often to distribute tokens, and how many should be given.

```julia
using Dates

const TOKEN_INTERVAL = Minute(30)
const TOKEN_INCREMENT = 100
```

Now, we can write a function to give out tokens on this interval, and get it running in the background.

```julia
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

function main()
    # ...
    @async distribute_tokens()
end
```

Next, we need to let users see their token count.
We can do this by adding a few helpers, and a *command* via [`add_command!`](@ref).

```julia
## Inserts guilds or users if necessary.
function ensure_updated(m::Discord.Message)
    if !haskey(TOKENS, m.guild_id)
        TOKENS[m.guild_id] = Dict()
    end
    if !haskey(TOKENS[m.guild_id], m.author)
        TOKENS[m.guild_id][m.author] = 0
    end
end

# Gets the token count for a user.
token_count(m::Discord.Message) = get(get(TOKENS, m.guild_id, Dict()), m.author, 0)

# Replies to a message with the author's token count.
function reply_token_count(c::Client, m::Discord.Message)
    ensure_updated(m)
    reply(c, m, "You have $(token_count(m)) tokens.")
end

function main()
    # ...
    add_command!(c, "!count", reply_token_count)
end
```

When a user types "!count", the bot will reply with their token count.
Next, we can easily implement the guild leaderboard for the "!leaderboard" command.

```julia
# Replies to a message with the guild's leaderboard.
function reply_token_leaderboard(c::Client, m::Discord.Message)
    ensure_updated(m.guild_id, m.author)

    # Get user => token count pairs by token count in descending order.
    sorted = sort(collect(TOKENS[m.guild_id]); by=p -> p.second, rev=true)

    entries = String[]
    for i in 1:min(10, length(sorted))  # Display at most 10.
        user, tokens = sorted[i]
        push!(entries, "$(user.username): $tokens")
    end

    reply(c, m, join(entries, "\n"))
end

function main()
    # ...
    add_command!(c, "!leaderboard", reply_token_leaderboard)
end
```

Next, we can implement the sending of tokens between users.
We need to do a few new things:

* Parse the number of tokens and the recipient from the command
* Check that the user sending the tokens has enough to send
* Check that both users are in the same guild

```julia
# Transfers tokens from one user to another.
function send_tokens(c::Client, m::Discord.Message)
    ensure_updated(m.guild_id, m.author)
    
    words = split(m.content)
    tokens = try
        parse(UInt, words[2])
    catch
        return reply(c, m, "'$(words[2])' is not a valid number of tokens.")
    end
    recipient = findfirst(u -> u.username == words[3], keys(TOKENS[m.guild_id]))

    if recipient === nothing
        return reply(c, m, "Coulnd't find user '$(words[3])' in this guild.")
    end
    if token_count(m.guild_id, m.author) < tokens
        return reply(c, m, "You don't have enough tokens to give.")
    end

    TOKENS[m.guild_id][m.author] -= tokens
    TOKENS[m.guild_id][recipient] += tokens
    reply(c, m, "You sent $tokens tokens to $(recipient.username).")
end

function main()
    # ...
    add_command!(c, "!send", send_tokens)
end
```

Easy!
And last but not least, we'll add the wagering command.

```julia
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
    # ...
    add_command!(c, "!wager", wager_tokens)
    wait(c)
end
```

The [`wait`](@ref) command at the end of `main` blocks until the client disconnects.
