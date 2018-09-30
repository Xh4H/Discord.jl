module Presence_updateEvent
    function executeEvent(mainClient, content)
        mainClient.send("PRESENCE_UPDATE", content)
    end
end
