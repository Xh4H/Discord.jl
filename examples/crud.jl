# This example mirrors rest.jl, but via the CRUD API.

module CRUD

using Discord

const GUILD = 494962347434049536  # Update this to a guild you have access to.

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
end

end

if abspath(PROGRAM_FILE) == @__FILE__
    CRUD.main()
end
