"""
A guild member.
More details [here](https://discordapp.com/developers/docs/resources/guild#guild-member-object).
"""
@from_dict struct Member
    user::Union{User, Missing}
    nick::Union{String, Missing}
    roles::Vector{Snowflake}
    joined_at::DateTime
    deaf::Bool
    mute::Bool
end
