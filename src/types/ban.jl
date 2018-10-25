"""
A [`User`](@ref) ban.
More details [here](https://discordapp.com/developers/docs/resources/guild#ban-object).
"""
struct Ban
    reason::Union{String, Nothing}
    user::User
end
@boilerplate Ban :dict :docs :lower :merge
