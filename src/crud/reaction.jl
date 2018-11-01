function retrieve(::Type{Reaction}, c::Client, m::Message, emoji::AbstractString)
    return get_reactions(c, m.channel_id, m.id, emoji)
end
retrieve(::Type{Reaction}, c::Client, m::Message, e::Emoji) = get(Reaction, c, m, e.name)

function create(::Type{Reaction}, c::Client, m::Message, emoji::AbstractString)
    return create_reaction(c, m.channel_id, m.id, emoji)
end
create(::Type{Reaction}, c::Client, m::Message, e::Emoji) = create(Reaction, c, m, e.name)

function delete(::Type{Reaction}, c::Client, m::Message)
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
