# Note: This is identical to Ready, but mutable.
mutable struct State
    v::Int
    user::User
    private_channels::Vector{DiscordChannel}
    guilds::Vector{UnavailableGuild}
    session_id::String
    _trace::Vector{String}
    presences::Union{Vector{Presence}, Nothing, Missing}
    relationships::Vector
end

function State(e::Ready)
    return State(
        e.v,
        e.user,
        e.private_channels,
        e.guilds,
        e.session_id,
        e._trace,
        e.presences,
        e.relationships,
    )
end
