module Guild_createEvent
    function executeEvent(mainClient, content)
        guildID = content["id"]

        members = content["members"]
        channels = content["channels"]
        emojis = content["emojis"]

        # Cache guilds to the client
        mainClient.guilds[guildID] = content

        # Cache users to client
        for member in members
            memberId = member["user"]["id"]
            user = member["user"]
            mainClient.users[memberId] = user
        end

        # Cache channels to client
        for channel in channels
            channelId = channel["id"]
            mainClient.channels[channelId] = channel
        end

        # Cache emojis to the client
        for emoji in emojis
            emojiId = emoji["id"]
            mainClient.emojis[emojiId] = emoji
        end

        mainClient.send("GUILD_CREATE", content)
    end
end
