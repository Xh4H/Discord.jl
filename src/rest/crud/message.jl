create(c::Client, ::Type{Message}, ch::DiscordChannel; kwargs...) = create_message(c, ch.id; kwargs...)

retrieve(c::Client, ::Type{Message}, ch::DiscordChannel, message::Integer) = get_channel_message(c, ch.id, message)
retrieve(
    c::Client,
    ::Type{Message},
    ch::DiscordChannel;
    pinned::Bool=false,
    kwargs...,
) = if pinned
        get_pinned_messages(c, ch.id)
    else
        get_channel_messages(c, ch.id; kwargs...)
    end

update(c::Client, m::Message; kwargs...) = edit_message(c, m.channel_id, m.id; kwargs...)

delete(c::Client, m::Message; pinned::Bool=false) = if pinned
        delete_pinned_channel_message(c, m.channel_id, m.id)
    else
        delete_message(c, m.channel_id, m.id)
    end
delete(c::Client, ms::Vector{Message}) = bulk_delete_messages(c, ms[1].channel_id; messages = map(m -> m.id, ms))
