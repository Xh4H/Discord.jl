module Julicord

    include("./API/Request.jl") # Request
    include("./Utils/Snowflake.jl") # Snowflake
    include("./Utils/Constants.jl") # Constants

    include("./WebSocket/Logger.jl") # WSLogger
    include("./Events/EventExporter.jl") # EventExporter
    include("./WebSocket/Handler.jl") # WSHandler
    include("./WebSocket/Manager.jl") # WSManager

    include("./Client.jl") # Client
    include("./Events/ready.jl") # Ready event

    include("./Structs/Emoji.jl") # Emoji struct
    include("./Structs/User.jl") # User struct
    include("./Structs/Webhook.jl") # Webhook struct



    export Client,
    Request,
    # Events
    EventExporter, ReadyEvent,
    # Structs
    Emoji, User, Webhook,
    # Utils
    Snowflake, Constants,
    WSManager, WSHandler, WSLogger

end # module
