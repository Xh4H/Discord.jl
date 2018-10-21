## Discord.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://purgepj.github.io/Discord.jl/stable)
[![Latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://purgepj.github.io/Discord.jl/latest)
[![Build Status](https://travis-ci.com/PurgePJ/Discord.jl.svg?branch=master)](https://travis-ci.com/PurgePJ/Discord.jl)
[![CodeCov](https://codecov.io/gh/PurgePJ/Discord.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/PurgePJ/Discord.jl)

<div align="center">
        <p> <img src="https://i.imgur.com/sOOlUnu.png"/> </p>
</div>

Discord.jl is the solution for creating [Discord](https://discordapp.com) bots with the [Julia programming language](https://julialang.org).

```julia
# Import Discord.jl.
using Discord
# Create a client.
c = Client("token")
# Add a handler for the MessageCreate event.
add_handler!(c, MessageCreate, (_, e) -> println("received message: $(e.message.content)"))
# Log in to the Discord gateway.
open(c)
# Wait for the client to disconnect.
wait(c)
```

For further examples, guides, and reference, please refer to the documentation linked above.

