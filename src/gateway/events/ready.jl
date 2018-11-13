export Ready

"""
Sent when the [`Client`](@ref) has authenticated, and contains the initial state.
"""
struct Ready <: AbstractEvent
    v::Int
    user::User
    private_channels::Vector{DiscordChannel}
    guilds::Vector{UnavailableGuild}
    session_id::String
    _trace::Vector{String}
end
@boilerplate Ready :constructors :docs
