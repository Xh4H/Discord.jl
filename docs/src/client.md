```@meta
CurrentModule = Discord
```

# Client

```@docs
Client
Base.open
Base.isopen
Base.close
Base.wait
me
```

## Event Handlers

See [Events](@ref) for more details.

```@docs
add_handler!
delete_handler!
```

## Bot Commands

```@docs
add_command!
```

## Gateway Commands

```@docs
request_guild_members
update_voice_state
update_status
```

## Caching

By default, most data that comes from Discord is cached for later use.
However, to avoid memory leakage, it's deleted after some time (initially set by the `ttl` keyword to the [`Client`](@ref) constructor and updated with [`set_ttl!`](@ref)).
Although it's not recommended, you can disable caching of certain data by clearing default handlers for relevant event types with [`delete_handler!`](@ref).
For example, if you wanted to avoid caching any messages, you would delete handlers for [`MessageCreate`](@ref) and [`MessageUpdate`](@ref) events.
You can also enable and disable the cache with [`enable_cache!`](@ref) and [`disable_cache!`](@ref).

```@docs
set_ttl!
enable_cache!
disable_cache!
```

## Sharding

Sharding is handled automatically: The number of available processes is the number of shards that are created.
See the [sharding example](https://github.com/PurgePJ/Discord.jl/blob/master/examples/sharding.jl) for more details.
