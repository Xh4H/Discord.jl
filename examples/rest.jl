# This example mirrors crud.jl, but via the REST API.

module REST

using Discord

# Set this environment variable or replace with your own guild ID.
const GUILD = parse(Discord.Snowflake, get(ENV, "DISCORD_GUILD_ID", "1234567890"))

function main()
    c = Client(ENV["DISCORD_TOKEN"])

    # Send a request.
    future = get_guild(c, GUILD)
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
    channel = fetchval(create_guild_channel(c, guild.id; name="foo"))

    # Send a message to the channel.
    message = fetchval(create_message(c, channel.id; content="Hello, world!"))
    # React to it.
    create_reaction(c, channel.id, message.id, '👍')
    # Edit it
    edit_message(c, channel.id, message.id; content="Goodbye, world!")
    # Delete it.
    delete_message(c, channel.id, message.id)

    # Delete the channel.
    delete_channel(c, channel.id)
end

end

if abspath(PROGRAM_FILE) == @__FILE__
    REST.main()
end
