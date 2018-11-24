export create,
    retrieve,
    update,
    delete

"""
    create(c::Client, ::Type{T}, args...; kwargs...) -> Future{Response}

Create, add, send, etc.

## Examples
Sending a [`Message`](@ref):
```julia
create(c, Message, channel; content="foo")
```
Creating a new [`DiscordChannel`](@ref):
```julia
create(c, DiscordChannel, guild; name="bar")
```
Banning a [`Member`](@ref):
```julia
create(c, Ban, guild, member; reason="baz")
```
"""
function create end

"""
    retrieve(c::Client, ::Type{T}, args...; kwargs...) -> Future{Response}

Retrieve, get, list, etc.

## Examples
Getting the [`Client`](@ref)'s [`User`](@ref):
```julia
retrieve(c, User)
```
Getting a [`Guild`](@ref)'s [`DiscordChannel`](@ref)s:
```julia
retrieve(c, DiscordChannel, guild)
```
Getting an [`Invite`](@ref) to a [`Guild`](@ref) by code:
```julia
retrieve(c, Invite, "abcdef")
```
"""
function retrieve end

"""
    update(c::Client, x::T, args...; kwargs...) -> Future{Response}

Update, edit, modify, etc.

## Examples
Editing a [`Message`](@ref):
```julia
update(c, message; content="foo2")
```
Modifying a [`Webhook`](@ref):
```julia
update(c, webhook; name="bar2")
```
Updating a [`Role`](@ref):
```julia
update(c, role, guild; permissions=8)
```
"""
function update end

"""
    delete(c::Client, x::T, args...) -> Future{Response}

Delete, remove, discard, etc.

## Examples
Kicking a [`Member`](@ref):
```julia
delete(c, member)
```
Unbanning a [`Member`](@ref):
```julia
delete(c, ban, guild)
```
Deleting all [`Reaction`](@ref)s from a [`Message`](@ref) (note: this is the only
update/delete method which takes a type parameter):
```julia
delete(c, Reaction, message)
```
"""
function delete end

include("audit_log.jl")
include("ban.jl")
include("channel.jl")
include("emoji.jl")
include("guild_embed.jl")
include("guild.jl")
include("integration.jl")
include("invite.jl")
include("member.jl")
include("message.jl")
include("overwrite.jl")
include("reaction.jl")
include("role.jl")
include("user.jl")
include("voice_region.jl")
include("webhook.jl")

#=
Functions not covered here:
- trigger_typing_indicator
- group_dm_add_recipient
- group_dm_remove_recipient
- modify_guild_channel_positions
- modify_current_user_nick
- modify_guild_role_positions
- get_guild_prune_count
- begin_guild_prune
- sync_guild_integration (combine with update?)
- get_guild_vanity_url
- get_guild_widget_image
- leave_guild (combine with delete?)
- execute_webhook
- execute_slack_compatible_webhook
- execute_github_compatible_webhook
=#
