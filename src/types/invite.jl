"""
An invite to a [`Guild`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/invite#invite-object).
"""
struct Invite
    code::String
    guild::Union{Guild, Missing}
    channel::DiscordChannel
    approximate_presence_cound::Union{Int, Missing}
    approximate_member_count::Union{Int, Missing}
end
@boilerplate Invite :dict :docs :lower :merge
