# An easy-to-construct AbstractEvent.
struct TestEvent <: AbstractEvent
    x
end
Discord.mock(::Type{TestEvent}) = TestEvent(rand())

# A module with event handlers.
module Handlers

export a, b

using Discord

a(::Client, ::AbstractEvent) = nothing
a(::Client, ::TypingStart) = nothing
b(::Client, ::WebhooksUpdate) = nothing
c(::Client, ::WebhooksUpdate) = nothing

end

@testset "Handlers" begin
    c = Client("token")
    f(c, e) = nothing
    g(c, e) = nothing
    badh(c, e::String) = nothing

    @testset "Basics" begin
        empty!(c.handlers)

        # Adding handlers without a tag means we can have duplicates.
        add_handler!(c, MessageCreate, f)
        add_handler!(c, MessageCreate, f)
        @test length(get(c.handlers, MessageCreate, Dict())) == 2

        # Deleting handlers without a tag clears all handlers for that type.
        delete_handler!(c, MessageCreate)
        @test !haskey(c.handlers, MessageCreate)

        # Using tags prevents duplicates.
        add_handler!(c, MessageCreate, f; tag=:f)
        add_handler!(c, MessageCreate, f; tag=:f)
        @test length(get(c.handlers, MessageCreate, Dict())) == 1
        @test haskey(c.handlers[MessageCreate], :f)

        # With tags, we can delete specific handlers.
        add_handler!(c, MessageCreate, g; tag=:g)
        @test length(get(c.handlers, MessageCreate, Dict())) == 2
        delete_handler!(c, MessageCreate, :g)
        @test length(get(c.handlers, MessageCreate, Dict())) == 1
        @test handler(c.handlers[MessageCreate][:f]) == f

        # We can also use do syntax.
        add_handler!(c, TypingStart) do c, e
            f(c, e)
        end
        @test length(get(c.handlers, TypingStart, Dict())) == 1
    end

    @testset "Adding from module" begin
        empty!(c.handlers)

        # We can add handlers from a module.
        add_handler!(c, Handlers)
        @test length(get(c.handlers, AbstractEvent, Dict())) == 1
        @test length(get(c.handlers, TypingStart, Dict())) == 1
        # Only exported functions are considered.
        @test length(get(c.handlers, WebhooksUpdate, Dict())) == 1
        @test handler(first(values(c.handlers[WebhooksUpdate]))) == Handlers.b

        # Adding a module handler with keywords propogates to all handlers.
        empty!(c.handlers)
        add_handler!(c, Handlers; tag=:h)
        @test all(hs -> all(p -> p.first === :h, hs), values(c.handlers))
    end

    @testset "Invalid handlers" begin
        # We can't add a handler without a valid method.
        @test_throws ArgumentError add_handler!(c, MessageCreate, badh)

        # We can't add a handler that's already expired.
        @test_throws ArgumentError add_handler!(c, Ready, f; count=0)
        @test_throws ArgumentError add_handler!(c, Ready, f; timeout=Day(-1))
    end

    @testset "Predicate functions" begin
        empty!(c.handlers)

        # By default, the predicate always returns true.
        add_handler!(c, TestEvent, f; tag=:f)
        @test predicate(c.handlers[TestEvent][:f]) == alwaystrue
        @test predicate(c.handlers[TestEvent][:f])(c, TestEvent(1))

        # But we can also specify our own.
        add_handler!(c, TestEvent, g; tag=:g, predicate=(c, e) -> e.x == 1)
        @test predicate(c.handlers[TestEvent][:g])(c, TestEvent(1))
        @test !predicate(c.handlers[TestEvent][:g])(c, TestEvent(2))
    end

    @testset "Fallback functions" begin
        # TODO
    end

    @testset "Expiries" begin
        empty!(c.handlers)

        # We can pass a number for a counting expiry.
        add_handler!(c, TestEvent, f; tag=:f, count=1)
        @test !isexpired(c.handlers[TestEvent][:f])
        dec!(c.handlers[TestEvent][:f])
        @test isexpired(c.handlers[TestEvent][:f])

        # Or we can use a timed expiry.
        add_handler!(c, TestEvent, g; tag=:g, timeout=Millisecond(100))
        @test !isexpired(c.handlers[TestEvent][:g])
        sleep(Millisecond(101))
        @test isexpired(c.handlers[TestEvent][:g])
    end

    @testset "Waiting" begin
        empty!(c.handlers)

        # Blocking handler with count should return when the count reaches 0.
        t = @async add_handler!(c, TestEvent, f; tag=:f, count=5, wait=true)
        sleep(Millisecond(1))
        h = c.handlers[TestEvent][:f]
        @test iscollecting(h)
        push!(h.results, 1)
        put!(h, results(h))
        h.remaining = 0
        sleep(Millisecond(150))
        @test istaskdone(t)
        @test fetch(t) == Any[1]

        # Blocking handler with timeout should return when the timeout elapses.
        t = @async add_handler!(c, TestEvent, f; tag=:g, timeout=Second(1), wait=true)
        sleep(Millisecond(1))
        h = c.handlers[TestEvent][:g]
        @test iscollecting(h)
        push!(h.results, 2)
        put!(h, results(h))
        sleep(1.1)
        @test istaskdone(t)
        @test fetch(t) == Any[2]

        # Blocking handler with both expiries should return when either is done.
        t = @async add_handler!(
            c, TestEvent, f;
            tag=:i, count=1, timeout=Day(1), wait=true,
        )
        sleep(Millisecond(1))
        h = c.handlers[TestEvent][:i]
        @test iscollecting(h)
        push!(h.results, 3)
        push!(h.results, 4)
        put!(h, results(h))
        h.remaining = -1
        sleep(Millisecond(150))
        @test istaskdone(t)
        @test fetch(t) == Any[3, 4]
    end

@testset "Handler collection" begin
    delete_handler!(c, Ready)
    add_handler!(c, Ready, f)
    add_handler!(c, Ready, f)
    add_handler!(c, AbstractEvent, f)
    add_handler!(c, FallbackEvent, f)
    @test length(handlers(c, Ready)) == 2

    # No handlers means no handlers.
    empty!(c.handlers)
    @test isempty(allhandlers(c, MessageCreate))
    @test isempty(allhandlers(c, AbstractEvent))
    @test isempty(allhandlers(c, FallbackEvent))

    # Both the specific and catch-all handler should match.
    add_handler!(c, Ready, f)
    add_handler!(c, AbstractEvent, f)
    @test allhandlers(c, Ready) == [
        collect(c.handlers[AbstractEvent]);
        collect(c.handlers[Ready]);
    ]

    # The fallback handler should only match if there are non non-default handlers.
    add_handler!(c, FallbackEvent, f)
    @test allhandlers(c, Ready) == [
        collect(c.handlers[AbstractEvent]);
        collect(c.handlers[Ready]);
    ]
    delete_handler!(c, Ready)
    @test allhandlers(c, Ready) == collect(c.handlers[AbstractEvent])
    add_handler!(c, Ready, f)
    delete_handler!(c, AbstractEvent)
    @test allhandlers(c, Ready) == collect(c.handlers[Ready])
    delete_handler!(c, Ready)
    add_handler!(c, Ready, f; tag=DEFAULT_HANDLER_TAG)
    @test allhandlers(c, Ready) == [
        collect(c.handlers[Ready]);
        collect(c.handlers[FallbackEvent]);
    ]
    delete_handler!(c, Ready)
    @test allhandlers(c, Ready) == collect(c.handlers[FallbackEvent])
end

@testset "Default handler lookup" begin
    c = Client("token")
    @test hasdefault(c, MessageCreate)
    delete_handler!(c, MessageCreate, DEFAULT_HANDLER_TAG)
    @test !hasdefault(c, MessageCreate)
    add_handler!(c, MessageCreate, f; tag=DEFAULT_HANDLER_TAG)
    @test hasdefault(c, MessageCreate)
end
end
