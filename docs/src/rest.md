```@meta
CurrentModule = Discord
```

# REST API

## Response

```@docs
Response
fetchval
```

## CRUD API

On top of functions for accessing individual endpoints such as [`get_channel_messages`](@ref), Discord.jl also offers a unified API with just four functions.
Named after [the **CRUD** model](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete), they cover most of the Discord REST API and allow you to write concise, expressive code, and forget about the subtleties of endpoint naming.
The argument ordering convention is roughly as follows:

1. A [`Client`](@ref), always.
2. For cases when we don't yet have the entity to be manipulated (usually [`create`](@ref) and [`retrieve`](@ref)), the entity's type.
   If we do have the entity ([`update`](@ref) and [`delete`](@ref)), the entity itself.
4. The remaining positional arguments supply whatever context is needed to specify the entity.
   For example, sending a message requires a [`DiscordChannel`](@ref) parameter.
5. Keyword arguments follow (usually for [`create`](@ref) and [`update`](@ref)).

```@docs
create
retrieve
update
delete
```

## Endpoints

Functions which wrap REST API endpoints are named and sorted according to the [Discord API documentation](https://discordapp.com/developers/docs/resources/audit-log).
Remember that the return types annotated below are not the actual return types, but the types of [`Response`](@ref) that the returned `Future`s will yield.

## Audit Log

```@docs
get_guild_audit_log
```

## Channel

```@docs
get_channel
modify_channel
delete_channel
get_channel_messages
get_channel_message
create_message
create_reaction
delete_own_reaction
delete_user_reaction
get_reactions
delete_all_reactions
edit_message
delete_message
bulk_delete_messages
edit_channel_permissions
get_channel_invites
create_channel_invite
delete_channel_permission
trigger_typing_indicator
get_pinned_messages
add_pinned_channel_message
delete_pinned_channel_message
group_dm_add_recipient
group_dm_remove_recipient
```

## Emoji

```@docs
list_guild_emojis
get_guild_emoji
create_guild_emoji
modify_guild_emoji
delete_guild_emoji
```

## Guild

```@docs
create_guild
get_guild
modify_guild
delete_guild
get_guild_channels
create_guild_channel
modify_guild_channel_positions
get_guild_member
list_guild_members
add_guild_member
modify_guild_member
modify_current_user_nick
add_guild_member_role
remove_guild_member_role
remove_guild_member
get_guild_bans
get_guild_ban
create_guild_ban
remove_guild_ban
get_guild_roles
create_guild_role
modify_guild_role_positions
modify_guild_role
delete_guild_role
get_guild_prune_count
begin_guild_prune
get_guild_voice_regions
get_guild_invites
get_guild_integrations
create_guild_integration
modify_guild_integration
delete_guild_integration
sync_guild_integration
get_guild_embed
modify_guild_embed
get_vanity_url
get_guild_widget_image
```

## Invite

```@docs
get_invite
delete_invite
```

## User

```@docs
get_current_user
get_user
modify_current_user
get_current_user_guilds
leave_guild
create_dm
create_group_dm
```

## Voice

```@docs
list_voice_regions
```

## Webhook

```@docs
create_webhook
get_channel_webhooks
get_guild_webhooks
get_webhook
get_webhook_with_token
modify_webhook
modify_webhook_with_token
delete_webhook
delete_webhook_with_token
execute_webhook
execute_slack_compatible_webhook
execute_github_compatible_webhook
```
