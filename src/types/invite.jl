export Invite

"""
An invite to a [`Guild`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/invite#invite-object).
"""
struct Invite
    code::String
    guild::Optional{Guild}
    channel::DiscordChannel
    approximate_presence_cound::Optional{Int}
    approximate_member_count::Optional{Int}
end
@boilerplate Invite :constructors :docs :lower :merge :mock
