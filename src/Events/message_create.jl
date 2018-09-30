module Message_createEvent
    function executeEvent(mainClient, content)
        mainClient.send("MESSAGE_CREATE", content)
    end
end
