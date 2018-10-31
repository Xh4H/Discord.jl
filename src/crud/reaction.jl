function retrieve(::Type{Reaction}, c::Client, m::Message, emoji::AbstractString)
    return get_reactions(c, m.channel_id, m.id, emoji)
end
retrieve(::Type{Reaction}, c::Client, m::Message, e::Emoji) = get(Reaction, c, m, e.name)

function create(::Type{Reaction}, c::Client, m::Message, emoji::AbstractString)
    return create_reaction(c, m.channel_id, m.id, emoji)
end
function create(::Type{Reaction}, c::Client, m::Message, e::Emoji)
    return create_reaction(c, m.channel_id, m.id, e.name)
end

function delete(c::Client, m::Message, emoji::AbstractString)
    return delete_all_reactions(c, m.channel_id, m.id, emoji)
end
function delete(c::Client, m::Message, e::Emoji)
    return delete_all_reactions(c, m.channel_id, m.id, e.name)
end

function delete(c::Client, m::Message, emoji::AbstractString, u::User)
    return if me(c) !== nothing && u.id == me(c).user.id
        delete_own_reaction(c, m.channel_id, m.id, emoji)
    else
        delete_reaction(c, m.channel_id, m.id, emoji, u.id)
    end
end
function delete(c::Client, m::Message, e::Emoji, u::User)
    return delete_reaction(c, m.channel_id, m.id, e.name, u.id)
end
