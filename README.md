<div align="center">
    <p> <img src="https://raw.githubusercontent.com/PurgePJ/Discord.jl/master/banner.png" alt="Discord.jl"/> </p>
</div>

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://purgepj.github.io/Discord.jl/stable)
[![Latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://purgepj.github.io/Discord.jl/latest)
[![Build Status](https://travis-ci.com/PurgePJ/Discord.jl.svg?branch=master)](https://travis-ci.com/PurgePJ/Discord.jl)

Discord.jl is the solution for creating [Discord](https://discordapp.com) bots with the [Julia programming language](https://julialang.org).

* Strong, expressive type system: No fast-and-loose JSON objects here.
* Non-blocking: API calls return immediately and can be awaited when necessary.
* Simple: Multiple dispatch allows for a [small, elegant core API](https://purgepj.github.io/Discord.jl/stable/rest.html#CRUD-API).
* Fast: Julia is [fast like C but still easy like Python](https://julialang.org/blog/2012/02/why-we-created-julia).
* Robust: You can't crash your bot with a bad event handler or request, and errors are visible to you for debugging.
* Lightweight: Cache what's important but shed dead weight with [TTL](https://en.wikipedia.org/wiki/Time_to_live).
* Gateway independent: Interact with Discord's API without establishing a gateway connection.
* Easy sharding: [Process-based sharding](https://purgepj.github.io/Discord.jl/stable/client.html#Sharding-1) requires next to no intervention and you can even run shards on separate machines.

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
For further examples, guides, and reference, please refer to the documentation linked above.

## Contributing

Pull requests are welcome!
In most cases, it will be helpful to discuss the change you'd like to make on [Discord](https://discord.gg/pjNUzy9) before diving in too deep.
