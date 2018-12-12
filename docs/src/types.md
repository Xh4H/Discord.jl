```@meta
CurrentModule = Discord
```

# Types

This page is organized in mostly-alphabetical order.
Note that `Snowflake ===  UInt64`, `Optional{T} === Union{T, Missing}`, `Nullable{T} === Union{T, Nothing}`, and `OptionalNullable{T} === Union{T, Missing, Nothing}`.
More details [here](https://discordapp.com/developers/docs/reference#nullable-and-optional-resource-fields).

Most of the time, you'll receive objects of these types as return values rather than creating them yourself.
However, should you wish to create your own instances from scratch, all of these types have keyword constructors.
If a field value can be `missing`, then its keyword is optional.

```@docs
Activity
ActivityTimestamps
ActivityParty
ActivityAssets
ActivitySecrets
ActivityType
ActivityFlags
Attachment
AuditLog
AuditLogEntry
AuditLogChange
AuditLogOptions
ActionType
Ban
DiscordChannel
ChannelType
Connection
Embed
EmbedThumbnail
EmbedVideo
EmbedImage
EmbedProvider
EmbedAuthor
EmbedFooter
EmbedField
Emoji
AbstractGuild
Guild
UnavailableGuild
VerificationLevel
MessageNotificationLevel
ExplicitContentFilterLevel
MFALevel
GuildEmbed
Integration
IntegrationAccount
Invite
InviteMetadata
Member
Message
MessageActivity
MessageApplication
MessageType
MessageActivityType
Overwrite
OverwriteType
Presence
PresenceStatus
Reaction
Role
User
VoiceRegion
VoiceState
Webhook
```
