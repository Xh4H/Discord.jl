@testset "REST API" begin
    @testset "Direct endpoint wrapper" begin
        # Direct endpoint wrappers should return a Future.
        f = get_channel_message(c, 123, 456)
        @test f isa Future
        # Since we don't have a valid token, we shouldn't get anything.
        @test fetchval(f) === nothing
        r = fetch(f)
        # But the type should still be sound.
        @test r isa Response{Message}
        @test !r.ok
        @test r.val === nothing
        @test r.http_response !== nothing
        @test r.exception === nothing
    end

    @testset "CRUD" begin
        # This API should behave just like the direct endpoint wrappers.
        f = create(c, Guild; name="foo")
        @test f isa Future
        r = fetch(f)
        @test r isa Response{Guild}
        @test r.val === nothing
        @test !r.ok
        @test r.http_response !== nothing
        @test r.exception === nothing
    end

    @testset "Simultaneous requests" begin
        # We should be able to make a bunch of requests without deadlocking.
        fs = map(i -> retrieve(c, Guild, i), 1:10)
        @test all(f -> f isa Future, fs)
        rs = fetch.(fs)
        @test all(r -> r isa Response{Guild}, rs)
    end

    @testset "Selective caching" begin
        f(c, e) = nothing

        # The regexes should be strict.
        @test all(
            p -> startswith(p, '^') && endswith(p, '$'),
            map(t -> t[1].pattern, vcat(values(EVENTS_FIRED)...)),
        )

        # We don't need to worry about this fast path.
        @eval Discord Base.isopen(::Client) = true

        # GETs should always be cached, because they never fire events.
        @test should_put(c, :GET, "foo")

        # If we have the default handler in place, we shouldn't put.
        add_handler!(c, MessageCreate, f; tag=DEFAULT_HANDLER_TAG)
        @test !should_put(c, :POST, "/channels/1/messages")

        # But if we delete it, then we should.
        delete_handler!(c, MessageCreate, DEFAULT_HANDLER_TAG)
        @test should_put(c, :POST, "/channels/1/messages")

        # For endpoints which fire multiple events, put unless they all have a default.
        add_handler!(c, GuildMemberRemove, f; tag=DEFAULT_HANDLER_TAG)
        add_handler!(c, PresenceUpdate, f; tag=DEFAULT_HANDLER_TAG)
        @test !should_put(c, :DELETE, "/users/@me/guilds/1")
        delete_handler!(c, PresenceUpdate, DEFAULT_HANDLER_TAG)
        @test should_put(c, :DELETE, "/users/@me/guilds/1")
    end
end
