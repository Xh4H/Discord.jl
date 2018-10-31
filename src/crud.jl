export create,
    retrieve,
    update,
    delete

include(joinpath("crud", "ban.jl"))
include(joinpath("crud", "audit_log.jl"))
include(joinpath("crud", "channel.jl"))
include(joinpath("crud", "emoji.jl"))
include(joinpath("crud", "guild.jl"))
include(joinpath("crud", "invite.jl"))
include(joinpath("crud", "member.jl"))
include(joinpath("crud", "message.jl"))
include(joinpath("crud", "overwrite.jl"))
include(joinpath("crud", "reaction.jl"))
include(joinpath("crud", "user.jl"))
