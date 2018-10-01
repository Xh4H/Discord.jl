module Typing_stopEvent

    function executeEvent(mainClient, content)
        mainClient.send("TYPING_STOP", content)
    end
end
