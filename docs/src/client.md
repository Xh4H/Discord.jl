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
heartbeat_ping
```

## Event Handlers

See [Events](@ref) for more details.

```@docs
add_handler!
delete_handler!
DEFAULT_HANDLER_TAG
```

## Bot Commands

```@docs
add_command!
delete_command!
add_help!
set_prefix!
```

## Gateway Commands

```@docs
request_guild_members
update_voice_state
update_status
```

## Caching

By default, most data that comes from Discord is cached for later use.
However, to avoid memory leakage, some of it is deleted after some time.
The default settings are to keep everything but [`Message`](@ref)s forever, but they can be overridden in the [`Client`](@ref) constructor.
Although it's not recommended, you can disable caching of certain data by clearing default handlers for relevant event types with [`delete_handler!`](@ref) and [`DEFAULT_HANDLER_TAG`](@ref).
For example, if you wanted to avoid caching any messages at all, you would delete handlers for [`MessageCreate`](@ref) and [`MessageUpdate`](@ref) events.
You can also enable and disable the cache with [`enable_cache!`](@ref) and [`disable_cache!`](@ref), which both support `do` syntax for temporarily altering behaviour.

```@docs
enable_cache!
disable_cache!
```

## Sharding

Sharding is handled automatically: The number of available processes is the number of shards that are created.
See the [sharding example](https://github.com/PurgePJ/Discord.jl/blob/master/examples/sharding.jl) for more details.
