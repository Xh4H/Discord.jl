@testset "Rate limiting" begin
    @testset "Queues" begin
        results = Nothing[]
        f() = (push!(results, nothing); nothing)
        l = Limiter()

        # We start with no queues.
        @test isempty(l.queues)
        # But when we need one, it gets created for us.
        enqueue!(f, l, :GET, "/foo")
        sleep(Millisecond(50))
        @test collect(keys(l.queues)) == ["/foo"]
        @test length(results) == 1

        n = now(UTC)
        q = l.queues["/foo"]
        q.remaining = 1
        q.reset = n + Millisecond(200)

        # If remaining > 0, we don't wait.
        enqueue!(f, l, :GET, "/foo")
        # But if remaining == 0, we do.
        sleep(Millisecond(50))
        q.remaining = 0
        enqueue!(f, l, :GET, "/foo")
        sleep(Millisecond(50))

        @test length(results) == 2
        sleep(Millisecond(250))
        @test length(results) == 3
    end

    @testset "parse_endpoint" begin
        # The variable parameter doesn't matter.
        @test parse_endpoint("/users/1", :GET) == "/users"

        # Unless it's one of these three.
        @test parse_endpoint("/channels/1", :GET) == "/channels/1"
        @test parse_endpoint("/guilds/1", :GET) == "/guilds/1"
        @test parse_endpoint("/webhooks/1", :GET) == "/webhooks/1"

        # Without a numeric parameter at the end, we get the whole endpoint.
        @test parse_endpoint("/users/@me/channels", :GET) == "/users/@me/channels"

        # Special case 1: Deleting messages.
        @test ==(
            parse_endpoint("/channels/1/messages/1", :DELETE),
            "/channels/1/messages DELETE",
        )
        @test parse_endpoint("/channels/1/messages/1", :GET) == "/channels/1/messages"

        # Special case 2: Invites.
        @test parse_endpoint("/invites/abcdef", :GET) == "/invites"
    end
end
