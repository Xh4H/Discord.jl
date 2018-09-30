module EventExporter
    include("ready.jl")
    include("presence_update.jl")

    import .ReadyEvent
    import .Presence_updateEvent
end
