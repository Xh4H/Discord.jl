export Ready

@from_dict struct Ready <: AbstractEvent
    v::Int
    user::User
    private_channels::Vector{DiscordChannel}
    guilds::Vector{UnavailableGuild}
    session_id::String
    _trace::Vector{String}
    # This isn't documented, but the name suggests that the entries will of type Presence.
    presences::Union{Vector{Presence}, Nothing, Missing}
    # This isn't documented and I can't tell what type the entries should be.
    relationships::Vector
end
