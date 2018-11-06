<div align="center">
    <p> <img src="https://raw.githubusercontent.com/PurgePJ/Discord.jl/master/banner.png" alt="Discord.jl"/> </p>
</div>

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://purgepj.github.io/Discord.jl/stable)
[![Latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://purgepj.github.io/Discord.jl/latest)
[![Build Status](https://travis-ci.com/PurgePJ/Discord.jl.svg?branch=master)](https://travis-ci.com/PurgePJ/Discord.jl)

Discord.jl is the solution for creating [Discord](https://discordapp.com) bots with the [Julia programming language](https://julialang.org).

## Why Julia/Discord.jl?

* Strong, expressive type system: No fast-and-loose JSON objects here.
* Non-blocking: API calls return immediately and can be awaited when necessary.
* Simple: Multiple dispatch allows for a small, elegant core API.
* Fast: Julia is fast like C but still easy like Python.
* Memory friendly: The usage of cache is very optimized and has the option to enable TTL (Time To Live).
* Gateway independent: Possibility to interact with Discord's API without establishing a Gateway connection.
* Easy sharding: The library manages the sharding of the clients.

## Example

```julia
# Import Discord.jl.
using Discord
# Create a client with a status.
presence = Dict("game" => Dict("name" => "With Discord.jl", "type" => 0), "status" => "dnd")
c = Client("token"; initial_presence=presence)

# Create a handler for the MessageCreate event.
function handler(c::Client, e::MessageCreate)
    # Display the message contents.
    println("Received message: $(e.message.content)")
    # Add a reaction to the message.
    create(c, Reaction, e.message, '👍')
end

# Add the handler.
add_handler!(c, MessageCreate, handler)
# Log in to the Discord gateway.
open(c)
# Wait for the client to disconnect.
wait(c)
```

## CRUD API
Discord.jl counts with a CRUD API, which eases the process of executing basic operations.

Functions are:
* Create
* Retrieve
* Update
* Delete

And the supported types are:
* Ban
* DiscordChannel
* Emoji
* GuildEmbed
* Guild
* Integration
* Invite
* Member
* Message
* Overwrite
* Reaction
* Role
* User
* VoiceRegion
* Webhook
  
Have a look at this [CRUD Example](https://github.com/PurgePJ/Discord.jl/blob/master/examples/CRUD_example.jl) to learn more about it.


For further examples, guides, and reference, please refer to the documentation linked above.

## Contributing

Pull requests are welcome!
In most cases, it will be helpful to discuss the change you'd like to make on [Discord](https://discord.gg/pjNUzy9) before diving in too deep.
