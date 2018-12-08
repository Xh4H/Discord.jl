```@meta
CurrentModule = Discord
```

# Types

This page is organized in mostly-alphabetical order.
Note that `Snowflake ===  UInt64`.
`Union`s with `Nothing` indicate that a field is nullable, whereas `Union`s with `Missing` indicate that a field is optional.
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
UserFlags
PremiumType
VoiceRegion
VoiceState
Webhook
```
