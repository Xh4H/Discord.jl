```@meta
CurrentModule = Discord
```

# Client

```@docs
Client
enable_cache!
disable_cache!
me
```

## Gateway

```@docs
Base.open
Base.isopen
Base.close
Base.wait
request_guild_members
update_voice_state
update_status
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
Splat
```
