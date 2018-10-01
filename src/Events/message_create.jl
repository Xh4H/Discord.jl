module Message_createEvent
    import ..Message

    function executeEvent(mainClient, content)
        Message.pretty(content)
        mainClient.send("MESSAGE_CREATE", content)
    end
end
