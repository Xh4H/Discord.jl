module Typing_startEvent

    function executeEvent(mainClient, content)
        mainClient.send("TYPING_START", content)
    end
end
