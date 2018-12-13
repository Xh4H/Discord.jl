using Dates
using Distributed
using InteractiveUtils
using JSON
using Test

using Discord
using Discord:
    EVENTS_FIRED,
    Conn,
    Empty,
    Handler,
    JobQueue,
    Limiter,
    Response,
    Snowflake,
    allhandlers,
    alwaystrue,
    datetime,
    dec!,
    enqueue!,
    get_channel_message,
    handler,
    handlers,
    hasdefault,
    increment,
    insert_or_update!,
    iscollecting,
    isexpired,
    logkws,
    mock,
    parse_endpoint,
    predicate,
    process_id,
    readjson,
    results,
    should_put,
    snowflake,
    snowflake2datetime,
    split_message,
    trywritejson,
    validate_fetch,
    worker_id,
    wrapfn!,
    writejson,
    @boilerplate,
    @constructors,
    @lower,
    @merge

c = Client("token")

@testset "Discord.jl" begin
    include("client.jl")
    include("parsing.jl")
    include("json.jl")
    include("helpers.jl")
    include("rest.jl")
    include("ratelimits.jl")
    include("boilerplate.jl")
    include("handlers.jl")
    include("commands.jl")
    include("state.jl")
end
