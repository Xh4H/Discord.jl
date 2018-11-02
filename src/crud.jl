export create,
    retrieve,
    update,
    delete

"""
    create(c::Client, ::Type{T}, args...; kwargs...)

Create, add, send, etc.

# Examples
```julia-repl
# Send a message.
julia> create(c, Message, channel; content="foo")

# Create a new channel.
julia> create(c, DiscordChannel, guild; name="bar")

# Ban a user.
julia> create(c, Ban, guild, user; reason="baz")
```
"""
function create end

"""
    retrieve(c::Client, ::Type{T}, args...; kwargs...)

Retreive, get, list, etc.

# Examples
```julia-repl
# Get the client user.
julia> retrieve(c, User)

# Get a guild's channels.
julia> retrieve(c, DiscordChannel, guild)

# Get an invite to a guild by code.
julia> retrieve(c, Invite, "abcdef")
```
"""
function retrieve end

"""
    update(c::Client, x::T, args...; kwargs...)

Update, edit, modify, etc.

# Examples
```julia-repl
# Edit a message.
julia> update(c, message; content="foo2")

# Modify a webhook.
julia> update(c, webhook; name="bar2")

# Update a role.
julia> update(c, role, guild; permissions=8)
```
"""
function update end

"""
    delete(c::Client, x::T, args...)

Delete, remove, discard, etc.

# Examples
```julia-repl
# Kick a user from a guild.
julia> delete(c, member)

# Unban a user from a guild.
julia> delete(c, ban, guild)

# Delete all reactions on a message.
# This is the only update/delete method which takes a type parameter.
delete(c, Reaction, message)
```
"""
function delete end

include(joinpath("crud", "audit_log.jl"))
include(joinpath("crud", "ban.jl"))
include(joinpath("crud", "channel.jl"))
include(joinpath("crud", "emoji.jl"))
include(joinpath("crud", "guild_embed.jl"))
include(joinpath("crud", "guild.jl"))
include(joinpath("crud", "integration.jl"))
include(joinpath("crud", "invite.jl"))
include(joinpath("crud", "member.jl"))
include(joinpath("crud", "message.jl"))
include(joinpath("crud", "overwrite.jl"))
include(joinpath("crud", "reaction.jl"))
include(joinpath("crud", "role.jl"))
include(joinpath("crud", "user.jl"))
include(joinpath("crud", "voice_region.jl"))
include(joinpath("crud", "webhook.jl"))

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
