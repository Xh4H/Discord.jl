module Guild_createEvent
    function executeEvent(mainClient, content)
        guildID = content["id"]
        mainClient.guilds[guildID] = content

        members = content["members"]
        channels = content["channels"]
        emojis = content["emojis"]

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

        for emoji in emojis
            emojiId = emoji["id"]
            mainClient.emojis[emojiId] = emoji
        end
    end
end
