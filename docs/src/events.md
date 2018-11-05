```@meta
CurrentModule = Discord
```

# Events

Note that `Snowflake === UInt64`.
`Union`s with `Nothing` indicate that a field is nullable, whereas `Union`s with `Missing` indicate that a field is optional.
More details [here](https://discordapp.com/developers/docs/reference#nullable-and-optional-resource-fields).

```@docs
AbstractEvent
FallbackEvent
UnknownEvent
```

## Channels

```@docs
ChannelCreate
ChannelUpdate
ChannelDelete
ChannelPinsUpdate
```

## Guilds

```@docs
GuildCreate
GuildUpdate
GuildDelete
GuildBanAdd
GuildBanRemove
GuildEmojisUpdate
GuildIntegrationsUpdate
GuildMemberAdd
GuildMemberRemove
GuildMemberUpdate
GuildMembersChunk
GuildRoleCreate
GuildRoleUpdate
GuildRoleDelete
```

## Messages

```@docs
MessageCreate
MessageUpdate
MessageDelete
MessageDeleteBulk
MessageReactionAdd
MessageReactionRemove
MessageReactionRemoveAll
```

## Presence

```@docs
PresenceUpdate
TypingStart
UserUpdate
```

## Voice

```@docs
VoiceStateUpdate
VoiceServerUpdate
```

## Webhooks

```@docs
WebhooksUpdate
```

## Connecting

```@docs
Ready
Resumed
```
