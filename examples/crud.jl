# This example mirrors rest.jl, but via the CRUD API.

module CRUD

using Discord

# Set this environment variable or replace with your own guild ID.
const GUILD = parse(Discord.Snowflake, get(ENV, "DISCORD_GUILD_ID", "1234567890"))

function main()
    c = Client(ENV["DISCORD_TOKEN"])

    # Send a request.
    future = retrieve(c, Guild, GUILD)
    # Then await it.
    resp = fetch(future)
    # Check for success.
    if !resp.ok
        # You can access the HTTP response if it went through.
        if resp.http_response !== nothing
            println("HTTP status: ", resp.http_response.status)
        end
        # You can also access caught exceptions.
        if resp.exception !== nothing
            println("Request error: ", sprint(showerror, resp.exception))
        end
        error("Retrieving guild failed")
    end

    # Get the actual Guild.
    guild = resp.val
    # If we're really confident, we can skip the error checks.
    guild = fetchval(future)

    println("Guild name: $(guild.name)")

    # Create a channel.
    channel = fetchval(create(c, DiscordChannel, guild; name="foo"))

    # Send a message to the channel.
    message = fetchval(create(c, Message, channel; content="Hello, world!"))
    # React to it.
    create(c, Reaction, message, '👍')
    # Edit it
    update(c, message; content="Goodbye, world!")
    # Delete it.
    delete(c, message)

    # Delete the channel.
    delete(c, channel)

    # Specific to CRUD: We can omit fetch/fetchval with macros.
    @fetch retrieve begin  # Here we're only wrapping calls to retrieve in fetch.
        resp = retrieve(c, Guild, GUILD)  # We don't have to call fetch.
        println("Response success: $(resp.ok)")
        future = create(c, DiscordChannel, resp.val; name="foo")  # Still returns a Future.
    end
    @fetchval retrieve create begin  # Wrapping calls to both retrieve and create.
        guild = retrieve(c, Guild, GUILD)  # We get the guild directly.
        println("Guild name: $(guild.name)")
        channel = create(c, DiscordChannel, guild; name="foo")  # We get the channel.
        future = update(c, channel; name="bar")  # Still returns a Future.
    end
    # If we don't specify any functions to wrap, they all get wrapped.
    @fetchval begin
        guild = retrieve(c, Guild, GUILD)
        channel = create(c, DiscordChannel, guild; name="foo")
        channel = update(c, channel; name="bar")
        delete(c, channel)
    end
end

end

if abspath(PROGRAM_FILE) == @__FILE__
    CRUD.main()
end
