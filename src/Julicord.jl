module Julicord

    include("./API/Request.jl") # Request
    include("./Utils/Snowflake.jl") # Snowflake
    include("./Utils/Constants.jl") # Constants

    include("./WebSocket/Logger.jl") # WSLogger
    include("./Events/EventExporter.jl") # EventExporter
    include("./WebSocket/Handler.jl") # WSHandler
    include("./WebSocket/Manager.jl") # WSManager

    include("./Client.jl") # Client

    include("./Structs/Emoji.jl") # Emoji struct
    include("./Structs/Message.jl") # Message struct
    include("./Structs/User.jl") # User struct
    include("./Structs/Webhook.jl") # Webhook struct

    include("./Events/ready.jl") # Ready event
    include("./Events/message_create.jl") # Message_create event
    include("./Events/presence_update.jl") # Presence_update event



    export Client,
    Request,
    # Events
    EventExporter, ReadyEvent, Presence_updateEvent, Message_createEvent
    # Structs
    Emoji, User, Message, Webhook,
    # Utils
    Snowflake, Constants,
    WSManager, WSHandler, WSLogger

end # module
