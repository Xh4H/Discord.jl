module Julicord

    include("./API/Request.jl") # Request
    include("./Utils/Snowflake.jl") # Snowflake
    include("./Utils/Constants.jl") # Constants

    include("./WebSocket/Logger.jl") # WSLogger
    include("./WebSocket/Handler.jl") # WSHandler
    include("./WebSocket/Manager.jl") # WSManager

    include("./Client.jl") # Client

    include("./Structs/Emoji.jl") # Emoji struct
    include("./Structs/Message.jl") # Message struct
    include("./Structs/User.jl") # User struct
    include("./Structs/Webhook.jl") # Webhook struct
    include("./Structs/Message.jl")

    include("./Events/ready.jl") # Ready event
    include("./Events/message_create.jl") # Message_create event
    include("./Events/presence_update.jl") # Presence_update event
    include("./Events/guild_create.jl") # Guild_create event



    export Client,
    Request,
    # Events
    ReadyEvent, Presence_updateEvent, Message_createEvent, Guild_createEvent,
    # Structs
    Emoji, User, Webhook, Message,
    # Utils
    Snowflake, Constants,
    WSManager, WSHandler, WSLogger

end # module
