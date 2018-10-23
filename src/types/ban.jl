"""
A [`User`](@ref) ban.
More details [here](https://discordapp.com/developers/docs/resources/guild#ban-object).
"""
@from_dict struct Ban
    reason::Union{String, Nothing}
    user::User
end
