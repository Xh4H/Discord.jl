module Guild_createEvent
    function executeEvent(mainClient, content)
        guildID = content["id"]
        mainClient.guilds[guildID] = content
        members = content["members"]

        for member in members
            memberId = member["user"]["id"]
            user = member["user"]
            mainClient.users[memberId] = user
        end
    end
end
