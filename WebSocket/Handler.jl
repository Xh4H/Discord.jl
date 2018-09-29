module WSHandler
    include("Logger.jl")
    include("../Events/EventExporter.jl")

    using Base
    using Dates
    import .WSLogger
    import JSON


    function handleEvent(data, client, mainClient)
        # println(data)
        eventName = lowercase(data["t"])
        content = data["d"]
        accessExporter = uppercasefirst("$(eventName)Event") |> Symbol
        @async begin
            try
                a = getfield(EventExporter, accessExporter)
                a.executeEvent(client, content, mainClient)
            catch err
                println(err)
                println("I'm not being able to handle $eventName yet")
            end
        end
    end
end
