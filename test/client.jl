@testset "Client" begin
    @testset "Token" begin
        # Tokens should always be prepended by "Bot ".
        c = Client("token")
        @test c.token == "Bot token"
        # Unless it's already there.
        c = Client("Bot token")
        @test c.token == "Bot token"
    end

    @testset "logkws" begin
        # We don't include the connection version or shard unless they're relevant.
        kws = Dict(logkws(c))
        @test haskey(kws, :time)
        @test !haskey(kws, :shard)
        @test !haskey(kws, :conn)
        c.shards += 1
        c.conn.io = IOBuffer()
        c.conn.v = 1
        kws = Dict(logkws(c))
        @test get(kws, :shard, nothing) == 0
        @test get(kws, :conn, nothing) == 1

        # We can add our own keywords.
        kws = Dict(logkws(c; x=1))
        @test get(kws, :x, nothing) == 1

        # We can also overwrite defaults.
        kws = logkws(c; time=0)
        @test length(count(p -> p.first === :time, kws)) == 1
        @test get(Dict(kws), :time, nothing) == 0

        # And we can hide defaults with undef.
        kws = Dict(logkws(c; time=undef))
        @test !haskey(kws, :time)
    end

    @testset "Utils" begin
        # We haven't connected to the gateway yet.
        @test me(c) === nothing

        disable_cache!(c)
        @test !c.use_cache
        enable_cache!(c) do
            @test c.use_cache
        end
        @test !c.use_cache
        enable_cache!(c)
        @test c.use_cache
        disable_cache!(c) do
            @test !c.use_cache
        end
        @test c.use_cache
    end
end
