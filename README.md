<div align="center">
    <p> <img src="https://raw.githubusercontent.com/Xh4H/Discord.jl/master/banner.png" alt="Discord.jl"/> </p>
</div>

| **Documentation** | **Build Status** | **Information** |
|:-:|:-:|:-:|
| [![Docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://xh4h.github.io/Discord.jl/dev) | [![Build Status](https://travis-ci.com/Xh4H/Discord.jl.svg?branch=master)](https://travis-ci.com/Xh4H/Discord.jl) | [![Discord](https://img.shields.io/badge/discord-join-7289da.svg)](https://discord.gg/ng9TjYd) [![License](https://img.shields.io/github/license/Xh4H/Discord.jl.svg)](https://github.com/Xh4H/Discord.jl/blob/master/LICENSE) |

Discord.jl is the solution for creating [Discord](https://discordapp.com) bots with the [Julia programming language](https://julialang.org).

* Strong, expressive type system: No fast-and-loose JSON objects here.
* Non-blocking: API calls return immediately and can be awaited when necessary.
* Simple: Multiple dispatch allows for a [small, elegant core API](https://xh4h.github.io/Discord.jl/stable/rest.html#CRUD-API-1).
* Fast: Julia is [fast like C but still easy like Python](https://julialang.org/blog/2012/02/why-we-created-julia).
* Robust: Resistant to bad event handlers and/or requests. Errors are introspectible for debugging.
* Lightweight: Cache what is important but shed dead weight with [TTL](https://en.wikipedia.org/wiki/Time_to_live).
* Gateway independent: Ability to interact with Discord's API without establishing a gateway connection.
* Distributed: [Process-based sharding](https://xh4h.github.io/Discord.jl/stable/client.html#Discord.Client) requires next to no intervention and you can even run shards on separate machines.

## Installation
First [install Julia](https://julialang.org/downloads/platform/). Make sure you are running the latest version.

Discord.jl is not yet released.
Add it from the Git repository with the following command:

```julia
# Enter ']' from the REPL to enter Pkg mode.
pkg> add https://github.com/Xh4H/Discord.jl
```
The above command will also update all of your dependencies, and store the
configurations in ~/.julia. 

## Example

```julia
# Import Discord.jl.
using Discord
# Create a client.
c = Client("token"; presence=(game=(name="with Discord.jl", type=AT_GAME),))

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

For further examples, guides and reference please refer to the documentation linked above.

## Contributing

Pull requests are welcome!
In most cases, it will be helpful to discuss the change you would like to make on [Discord](https://discord.gg/ng9TjYd) before diving in too deep.

## Credits

Big thanks to [christopher-dG](https://github.com/christopher-dG) for developing this project with me, and also [TheOnlyArtz](https://github.com/TheOnlyArtz) for initially starting up this repository with me.
