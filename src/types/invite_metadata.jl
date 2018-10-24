"""
Metadata for an [`Invite`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/invite#invite-metadata-object).
"""
struct InviteMetadata
    inviter::User
    uses::Int
    max_uses::Int
    max_age::Int
    temporary::Bool
    created_at::DateTime
    revoked::Bool
end
@boilerplate InviteMetadata :dict :lower :merge
