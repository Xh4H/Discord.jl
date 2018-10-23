using Discord:
    Client,
    Snowflake,
    snowflake,
    snowflake2datetime,
    worker_id,
    process_id,
    increment,
    datetime,
    @from_dict,
    parse_endpoint

using Dates
using Test

# A test case which covers most possible field types.
@from_dict struct Foo
    a::String
    b::DateTime
    c::Snowflake
    d::Vector{String}
    e::Union{Int, Nothing}
    f::Union{Int, Missing}
    g::Union{Vector{String}, Nothing, Missing}
end

# A test case which is a subtype.
@from_dict struct Bar <: Integer
    a::Int
end

@testset "Discord.jl" begin
    @testset "Client token" begin
        c = Client("token")
        @test c.token == "Bot token"
        c = Client("Bot token")
        @test c.token == "Bot token"
    end

    @testset "Snowflake" begin
        s = snowflake(string(typemax(UInt64)))
        @test isa(s, UInt64)
        @test s == typemax(UInt64)

        s = Snowflake(0x06ecefa78e42000c)
        @test snowflake2datetime(s) == DateTime(2018, 10, 9, 1, 55, 31, 1)
        @test worker_id(s) == 0x01
        @test process_id(s) == 0x00
        @test increment(s) == 0x0c
    end

    @testset "DateTime parsing" begin
        d = datetime("2018-10-08T05:20:22.782643+00:00")
        @test d == DateTime(2018, 10, 8, 5, 20, 22, 782)

        d = datetime("2018-10-08T05:20:22.782Z")
        @test d == DateTime(2018, 10, 8, 5, 20, 22, 782)
    end

    @testset "@from_dict" begin
        d = Dict(
            "a" => "foo",
            "b" => "2018-10-08T05:20:22.782Z",
            "c" => "1234567890",
            "d" => ["a", "b", "c"],
            "e" => 1,
            "f" => 2,
            "g" => ["a", "b", "c"],
        )

        f = Foo(d)
        @test f.a == "foo"
        @test f.b == DateTime(2018, 10, 8, 5, 20, 22, 782)
        @test f.c == 1234567890
        @test f.d == ["a", "b", "c"]
        @test f.e == 1
        @test f.f == 2
        @test f.g == ["a", "b", "c"]
        @test isempty(f.extra_fields)

        d["e"] = nothing
        delete!(d, "f")
        delete!(d, "g")

        f = Foo(d)
        @test f.e === nothing
        @test ismissing(f.f)
        @test ismissing(f.g)

        d["g"] = nothing

        f = Foo(d)
        @test f.g === nothing

        b = Bar(Dict("a" => 1, "b" => "foo"))
        @test b.a == 1
        @test b.extra_fields == Dict("b" => "foo")
    end

    @testset "parse_endpoint" begin
        # The variable paramter doesn't matter.
        @test parse_endpoint("/users/1", :GET) == "/users"
        # Unless it's one of these three.
        @test parse_endpoint("/channels/1", :GET) == "/channels/1"
        @test parse_endpoint("/guilds/1", :GET) == "/guilds/1"
        @test parse_endpoint("/webhooks/1", :GET) == "/webhooks/1"

        # Without a numeric parameter at the end, we get the whole endpoint.
        @test parse_endpoint("/users/@me/channels", :GET) == "/users/@me/channels"

        # Special case: Deleting messages.
        @test ==(
            parse_endpoint("/channels/1/messages/1", :DELETE),
            "/channels/1/messages DELETE",
        )
        @test parse_endpoint("/channels/1/messages/1", :GET) == "/channels/1/messages"
    end
end
