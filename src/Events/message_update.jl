module Message_updateEvent

    function executeEvent(mainClient, content)
        mainClient.send("MESSAGE_UPDATE", content)
    end
end
