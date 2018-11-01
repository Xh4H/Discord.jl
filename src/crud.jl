export create,
    retrieve,
    update,
    delete

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
- get_user_connections
- execute_webhook
- execute_slack_compatible_webhook
- execute_github_compatible_webhook
=#
