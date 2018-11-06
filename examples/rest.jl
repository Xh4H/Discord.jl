# This example mirrors crud.jl, but via the REST API.

module REST

using Discord

const GUILD = 494962347434049536  # Update this to a guild you have access to.

function main()
    c = Client(ENV["DISCORD_TOKEN"])

    # Send a request.
    future = Discord.get_guild(c, GUILD)
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
    channel = fetchval(Discord.create_guild_channel(c, guild.id; name="foo"))

    # Send a message to the channel.
    message = fetchval(Discord.create_message(c, channel.id; content="Hello, world!"))
    # React to it.
    Discord.create_reaction(c, channel.id, message.id, '👍')
    # Edit it
    Discord.edit_message(c, channel.id, message.id; content="Goodbye, world!")
    # Delete it.
    Discord.delete_message(c, channel.id, message.id)

    # Delete the channel.
    Discord.delete_channel(c, channel.id)
end

end

if abspath(PROGRAM_FILE) == @__FILE__
    REST.main()
end
