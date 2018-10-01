module WSHandler

    import ..WSLogger

    using Base
    using Dates
    import .WSLogger
    import JSON


    function handleEvent(mainClient, data)
        eventName = lowercase(data["t"])
        content = data["d"]
        accessExporter = uppercasefirst("$(eventName)Event") |> Symbol
        @eval import ...$accessExporter
        @async begin
            try
                @eval $accessExporter.executeEvent($mainClient, $content)
            catch err
                println(err)
                println("I'm not being able to handle $eventName yet")
            end
        end
    end
end
