using Distributed

nprocs() == 1 && addprocs(1)

@everywhere module Sharding

using Discord

handler(c::Client, e::AbstractEvent) = println("shard $(c.shard) received $(typeof(e))")

function main()
    c = Client(ENV["DISCORD_TOKEN"])
    add_handler!(c, AbstractEvent, handler)
    open(c)
    wait(c)
end

end

if abspath(PROGRAM_FILE) == @__FILE__
    @everywhere Sharding.main()
end
