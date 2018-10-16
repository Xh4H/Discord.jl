## Discord.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://purgepj.github.io/Discord.jl/stable)
[![Latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://purgepj.github.io/Discord.jl/latest)
[![Build Status](https://travis-ci.com/PurgePJ/Discord.jl.svg?branch=master)](https://travis-ci.com/PurgePJ/Discord.jl)
[![CodeCov](https://codecov.io/gh/PurgePJ/Discord.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/PurgePJ/Discord.jl)

### Example

```julia
using Discord
c = Client("token")
add_handler!(c, MessageDelete, (_, e) -> println("message $(e.id) was deleted"))
open(c)
wait(c)
```
### Sharding

```julia
using Distributed
addprocs(2)
@everywhere begin
    using Discord
    c = Client("token")
    add_handler!(c, AbstractEvent, (c, e) -> println("[shard $(c.shard)] received $(typeof(e))"))
    open(c)
    wait(c)
end
```
