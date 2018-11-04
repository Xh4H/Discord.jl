function retrieve(
    c::Client,
    ::Type{Reaction},
    m::Message,
    emoji::Union{AbstractString, AbstractChar},
)
    return get_reactions(c, m.channel_id, m.id, emoji)
end
retrieve(c::Client, ::Type{Reaction}, m::Message, e::Emoji) = get(Reaction, c, m, e.name)

function create(
    c::Client,
    ::Type{Reaction},
    m::Message,
    emoji::Union{AbstractString, AbstractChar},
)
    return create_reaction(c, m.channel_id, m.id, emoji)
end
create(c::Client, ::Type{Reaction}, m::Message, e::Emoji) = create(Reaction, c, m, e.name)

function delete(c::Client, ::Type{Reaction}, m::Message)
    return delete_all_reactions(c, m.channel_id, m.id)
end
function delete(
    c::Client,
    emoji::Union{AbstractString, AbstractChar},
    m::Message,
    u::User,
)
    return if c.state.user !== nothing && u.id == c.state.user.id
        delete_own_reaction(c, m.channel_id, m.id, emoji)
    else
        delete_user_reaction(c, m.channel_id, m.id, emoji, u.id)
    end
end
delete(c::Client, e::Emoji, m::Message, u::User) = delete(c, m, e.name, u)
