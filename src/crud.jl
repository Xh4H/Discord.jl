export create,
    retrieve,
    update,
    delete

"""
    create(c::Client, ::Type{T}, args...; kwargs...)

Create, add, send, etc.

# Examples
```julia-repl
# Send a [`Message`](@ref).
julia> create(c, Message, channel; content="foo")

# Create a new [`DiscordChannel`](@ref).
julia> create(c, DiscordChannel, guild; name="bar")

# Ban a [`Member`](@ref).
julia> create(c, Ban, guild, member; reason="baz")
```
"""
function create end

"""
    retrieve(c::Client, ::Type{T}, args...; kwargs...)

Retrieve, get, list, etc.

# Examples
```julia-repl
# Get the Client user.
julia> retrieve(c, User)

# Get a [`Guild`](@ref)'s channels.
julia> retrieve(c, DiscordChannel, guild)

# Get an [`Invite`](@ref) to a [`Guild`](@ref) by code.
julia> retrieve(c, Invite, "abcdef")
```
"""
function retrieve end

"""
    update(c::Client, x::T, args...; kwargs...)

Update, edit, modify, etc.

# Examples
```julia-repl
# Edit a [`Message`](@ref).
julia> update(c, message; content="foo2")

# Modify a [`Webhook`](@ref).
julia> update(c, webhook; name="bar2")

# Update a [`Role`](@ref).
julia> update(c, role, guild; permissions=8)
```
"""
function update end

"""
    delete(c::Client, x::T, args...)

Delete, remove, discard, etc.

# Examples
```julia-repl
# Kick a [`Member`](@ref).
julia> delete(c, member)

# Unban a [`Member`](@ref).
julia> delete(c, ban, guild)

# Delete all [`Reaction`](@ref)s from a [`Message`](@ref).
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
