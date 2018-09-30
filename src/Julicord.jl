module Julicord
    include("./Client.jl")
    include("./API/Request.jl")
    # Events
    include("./Events/ready.jl")
    include("./Events/EventExporter.jl")
    # Structs
    include("./Structs/Emoji.jl")
    include("./Structs/User.jl")
    include("./Structs/Webhook.jl")
    # Utils
    include("./Utils/Snowflake.jl")
    include("./Utils/Constants.jl")

    export Client,
    Request,
    # Events
    EventExporter, ReadyEvent,
    # Structs
    Emoji, User, Webhook,
    # Utils
    Snowflake, Constants

end # module
