module Julicord

    include("./API/Request.jl")
    # Utils
    include("./Utils/Snowflake.jl")
    include("./Utils/Constants.jl")
    # WebSocket
    include("./WebSocket/Logger.jl")
    include("./Events/EventExporter.jl")
    include("./WebSocket/Handler.jl")
    include("./WebSocket/Manager.jl")

    include("./Client.jl")
    include("./Events/ready.jl")
    
    # Structs
    include("./Structs/Emoji.jl")
    include("./Structs/User.jl")
    include("./Structs/Webhook.jl")



    # export Client,
    # Request,
    # # Events
    # EventExporter, ReadyEvent,
    # # Structs
    # Emoji, User, Webhook,
    # # Utils
    # Snowflake, Constants,
    # Manager, Handler, Logger

end # module
