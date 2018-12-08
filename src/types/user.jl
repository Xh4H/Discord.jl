export User

"""
[`User`](@ref) flags, which indicate HypeSquad status.
"""
@enum UserFlags HS_EVENTS=1<<2 HS_BRAVERY=1<<6 HS_BRILLIANCE=1<<7 HS_BALANCE=1<<8
@boilerplate UserFlags :export

"""
[`User`](@ref) Discord Nitro status.
"""
@enum PremiumType PT_NITRO_CLASSIC=1 PT_NITRO=2
@boilerplate PremiumType :export

"""
A Discord user.
More details [here](https://discordapp.com/developers/docs/resources/user#user-object).
"""
struct User
    id::Snowflake
    # The User inside of a Presence only needs its ID set.
    username::Union{String, Missing}
    discriminator::Union{String, Missing}
    avatar::Union{String, Nothing, Missing}
    bot::Union{Bool, Missing}
    mfa_enabled::Union{Bool, Missing}
    locale::Union{String, Missing}
    verified::Union{Bool, Missing}
    email::Union{String, Nothing, Missing}  # Not supposed to be nullable.
    flags::Union{Int, Missing}
    premium_type::Union{PremiumType, Missing}
end
@boilerplate User :constructors :docs :lower :merge :mock
