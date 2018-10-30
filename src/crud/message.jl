function get(::Type{Message}, c::Client, ch::DiscordChannel, message::Snowflake)
    return get_message(c, ch.id, message)
end
function get(::Type{Message}, c::Client, ch::DiscordChannel, message::Integer)
    return get(Message, c, ch.id, snowflake(message))
end

function create(::Type{Message}, c::Client, channel::DiscordChannel; kwargs...)
    return create_message(c, ch.id; kwargs...)
end

edit(c::Client, m::Message) = edit_message(c, m.channel_id, m.id; kwargs...)
delete(c::Client, m::Message) = delete_message(c, m.channel_id, m.id)

function get(::Type{Vector{Message}}, c::Client, ch::DiscordChannel; kwargs...)
    return get_messages(c, ch.id; kwargs...)
end

function delete(c::Client, ms::Vector{Message})
    return bulk_delete_messages(c, ms[1].channel_id, map(m -> m.id, ms))
end
