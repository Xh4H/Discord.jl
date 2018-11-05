module CrudExample

using Discord

function main()
    c = Client(ENV["token"])
    open(c)

    # Available CRUD types:
    # · AuditLog
    # · Ban
    # · DiscordChannel
    # · Emoji
    # · GuildEmbed
    # · Guild
    # · Integration
    # · Invite
    # · Member
    # · Message
    # · Overwrite
    # · Reaction
    # · Role
    # · User
    # · VoiceRegion
    # · Webhook

    # CRUD format:
    # create(Client, CRUDType, param 1[, param n...][;kwargs])
    # retrieve(Client, CRUDType, param 1[, param n...][;kwargs])
    # update(Client, param 1[, param n...][;kwargs])
    # delete(Client, param 1[, param n...])

    # Retrieving a channel
    test_channel = retrieve(c, DiscordChannel, 508717799405781003) # -> Distributed.Future
    # Returns a Future, to fetch the value:
    channel_val = fetch(test_channel).val # We get the value from the fetched Response
    channel_name = channel_val.name
    # Or a synonim of the above
    channel_name = fetchval(test_channel).name
    # Or REST way
    rest_channel = fetchval(get_channel(c, 508717799405781003))
    rest_channel_name = rest_channel.name

    # Deleting a guild
    guild_to_delete = get_guild(c, 81384788765712384)
    delete(c, fetchval(guild_to_delete))
    # Or a synonym of the above
    delete_guild(c, 81384788765712384)
    
    return c
end

end

if abspath(PROGRAM_FILE) == @__FILE__
    c = CrudExample.main()
    wait(c)
end
