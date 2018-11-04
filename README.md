<div align="center">
    <p> <img src="https://raw.githubusercontent.com/PurgePJ/Discord.jl/master/banner.png" alt="Discord.jl"/> </p>
</div>

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://purgepj.github.io/Discord.jl/stable)
[![Latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://purgepj.github.io/Discord.jl/latest)
[![Build Status](https://travis-ci.com/PurgePJ/Discord.jl.svg?branch=master)](https://travis-ci.com/PurgePJ/Discord.jl)

Discord.jl is the solution for creating [Discord](https://discordapp.com) bots with the [Julia programming language](https://julialang.org).

```julia
# Import Discord.jl.
using Discord
# Create a client.
c = Client("token")

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
