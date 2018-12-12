export Member

"""
A [`Guild`](@ref) member.
More details [here](https://discordapp.com/developers/docs/resources/guild#guild-member-object).
"""
struct Member
    user::Optional{User}
    nick::Union{String, Nothing, Missing}  # Not supposed to be nullable.
    roles::Vector{Snowflake}
    joined_at::DateTime
    deaf::Bool
    mute::Bool
end
@boilerplate Member :constructors :docs :lower :merge :mock
