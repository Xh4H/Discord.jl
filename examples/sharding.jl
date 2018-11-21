using Distributed

nprocs() == 1 && addprocs(1)

@everywhere module Sharding

using Discord

function main()
    c = Client(ENV["DISCORD_TOKEN"])

    add_handler!(c, AbstractEvent) do c, e
        println("Shard $(c.shard) received $(typeof(e))")
    end

    open(c)
    return c
end

end

if abspath(PROGRAM_FILE) == @__FILE__
    @everywhere begin
        c = Sharding.main()
        wait(c)
    end
end
