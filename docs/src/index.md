# Discord.jl

Discord.jl is the solution for creating [Discord](https://discordapp.com) bots with the [Julia programming language](https://julialang.org).

## Why Julia/Discord.jl?

* Strong, expressive type system: No fast-and-loose JSON objects here.
* Non-blocking: API calls return immediately and can be awaited when necessary.
* Simple: Multiple dispatch allows for a [small, elegant core API](rest.md#CRUD-API-1).
* Fast: Julia is [fast like C but still easy like Python](https://julialang.org/blog/2012/02/why-we-created-julia).
* Robust: You can't crash your bot with a bad event handler or request, and errors are introspectible for debugging.
* Lightweight: Cache what's important but shed dead weight with [TTL](https://en.wikipedia.org/wiki/Time_to_live).
* Gateway independent: Interact with Discord's API without establishing a gateway connection.
* Distributed: [Process-based sharding](client.md#Sharding-1) requires next to no intervention and you can even run shards on separate machines.

For usage examples, see the [`examples/` directory](https://github.com/PurgePJ/Discord.jl/tree/master/examples).

## Index

```@index
```
