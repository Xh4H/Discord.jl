function retrieve(c::Client, ::Type{Reaction}, m::Message, emoji::AbstractString)
    return get_reactions(c, m.channel_id, m.id, emoji)
end
retrieve(c::Client, ::Type{Reaction}, m::Message, e::Emoji) = get(Reaction, c, m, e.name)

function create(c::Client, ::Type{Reaction}, m::Message, emoji::AbstractString)
    return create_reaction(c, m.channel_id, m.id, emoji)
end
create(c::Client, ::Type{Reaction}, m::Message, e::Emoji) = create(Reaction, c, m, e.name)

function delete(c::Client, ::Type{Reaction}, m::Message)
    return delete_all_reactions(c, m.channel_id, m.id)
end
function delete(c::Client, m::Message, emoji::AbstractString, u::User)
    return if me(c) !== nothing && u.id == me(c).user.id
        delete_own_reaction(c, m.channel_id, m.id, emoji)
    else
        delete_user_reaction(c, m.channel_id, m.id, emoji, u.id)
    end
end
delete(c::Client, m::Message, e::Emoji, u::User) = delete(c, m, e.name, u)
