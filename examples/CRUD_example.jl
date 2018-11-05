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
    # create(Client, CRUDType, param 1[, param n...])
    # retrieve(Client, CRUDType, param 1[, param n...])
    # update(Client, CRUDType, param 1[, param n...])
    # delete(Client, CRUDType, param 1[, param n...])

    # Retrieving a channel
    test_channel = retrieve(c, DiscordChannel, 508717799405781003) # -> Distributed.Future
    # Returns a Future, to fetch the value:
    channel_val = fetch(test_channel).val # We get the value from the fetched Response
    channel_name = channel_val.name

    # Deleting a guild
    delete(c, Guild, 81384788765712384)
    return c
end

end

if abspath(PROGRAM_FILE) == @__FILE__
    c = CrudExample.main()
    wait(c)
end
