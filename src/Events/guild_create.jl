module Guild_createEvent
    function executeEvent(mainClient, content)
        guildID = content["id"]
        mainClient.guilds[guildID] = content

        members = content["members"]

        for i in members
            mainClient.users[i["user"]["id"]] = i["user"]
        end
    end
end
