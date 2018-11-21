module Events

using Dates
using Discord

function on_message_create(c::Client, e::MessageCreate)
    e.message.content == "ping" && reply(c, e.message, "pong")
end

function predicate(c::Client, e::MessageCreate)
    return e.message.content == "ping"
end

function main()
    c = Client(ENV["DISCORD_TOKEN"])
    open(c)

    # This handler runs on all MessageCreate events.
    add_handler!(c, MessageCreate, on_message_create; tag=:ping)
    # We can simplify the above handler with a predicate function and do syntax.
    add_handler!(c, MessageCreate; tag=:ping, predicate=predicate) do c, e
        reply(c, e.message, "pong")
    end
    # This handler runs on events which have no non-default handler.
    add_handler!(c, FallbackEvent, (c, e) -> println("Unhandled event: $(typeof(e))"))
    # This handler runs on all events. The FallbackEvent handler will no longer run.
    add_handler!(c, AbstractEvent, (c, e) -> println("Event: $(typeof(e))"))
    # You can add counting or timed expiries. This handler runs 3 times or for 10 seconds.
    add_handler!(c, TypingStart, (c, e) -> println("Typing"); n=3, timeout=Second(10))
    # You can aggregate results with a blocking handler.
    msgs = add_handler!(c, MessageCreate, (c, e) -> e.message.content; n=3, wait=true)
    println("Received 3 messages: ", msgs)

    return c
end

end

if abspath(PROGRAM_FILE) == @__FILE__
    c = Events.main()
    wait(c)
end
