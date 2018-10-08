@from_dict struct Invite
    code::String
    guild::Union{Guild, Nothing}
    channel::DiscordChannel
    approximate_presence_cound::Union{Int, Nothing}
    approximate_member_count::Union{Int, Nothing}
end
