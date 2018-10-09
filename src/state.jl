mutable struct State
    v::Int                              # Discord API version.
    session_id::String                  # Gateway session ID.
    _trace::Vector{String}              # Guilds the user is in.
    user::Union{User, Nothing}          # Bot user.
    events::Vector{AbstractEvent}       # Events received by the client.
    guilds::Dict{Snowflake, AbstractGuild}     # Guild ID -> guild.
    channels::Dict{Snowflake, DiscordChannel}  # Channel ID -> channel.
    users::Dict{Snowflake, User}               # User ID -> user.
    messages::Dict{Snowflake, Message}         # Message ID -> message.
    # Guild ID -> user ID -> presence.
    # If a presence appears with a guild ID attached, then it's stored in that guild.
    # If the guild ID field is missing, the presence is appended to the missing key's value.
    presences::Dict{Union{Snowflake, Missing}, Dict{Snowflake, Presence}}
    # Guild ID -> member ID -> member.
    # If a member appears with a user object attached, then it's stored by user ID.
    # If the user field is missing, the member is appended to the missing key's value.
    members::Dict{Snowflake, Dict{Union{Snowflake, Missing}, Union{Member, Vector{Member}}}}
end

State() = State(0, "", [], nothing, [], Dict(), Dict(), Dict(), Dict(), Dict(), Dict())

function ready(s::State, e::Ready)
    s.v = e.v
    s.session_id = e.session_id
    s._trace = e._trace
    s.user = e.user

    for c in e.private_channels
        # Overwrite here because the data is more recent.
        s.channels[e.id] = e
    end
    for g in e.guilds
        # Don't overwrite anuthing here because these guilds are unavailable.
        if !haskey(s.guilds, g.id)
            s.guilds[g.id] = g
        end
    end
    for p in s.presences
        # Overwrite here because the data is more recent.
        if !haskey(s.presences, p.guild_id)
            s.presences[p.guild_id] = Dict()
        end
        s.guilds[p.guild_id][p.user.id] = p
    end
end
