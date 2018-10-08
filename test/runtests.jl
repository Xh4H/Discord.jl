using Julicord:
    Client,
    Snowflake,
    snowflake,
    datetime,
    @from_dict

using Dates
using Test

# A test case which covers all possible field types.
@from_dict struct Foo
    x::String
    y::DateTime
    z::Snowflake
    a::Vector{String}
    b::Union{Int, Nothing}
    c::Union{Int, Missing}
end

# A test case which is a subtype.
@from_dict struct Bar <: Integer
    x::Int
end

@testset "Julicord" begin
    @testset "Client token" begin
        c = Client("token")
        @test c.token == "Bot token"
        c = Client("Bot token")
        @test c.token == "Bot token"
    end

    @testset "Snowflake parsing" begin
        s = snowflake("1234567890")
        @test isa(s, Int64)
        @test s == 1234567890
    end

    @testset "DateTime parsing" begin
        d = datetime("2018-10-08T05:20:22.782Z")
        @test d == DateTime(2018, 10, 8, 5, 20, 22, 782)
    end

    @testset "@from_dict" begin
        d = Dict(
            "x" => "foo",
            "y" => "2018-10-08T05:20:22.782Z",
            "z" => "1234567890",
            "a" => ["a", "b", "c"],
            "b" => 1,
            "c" => 2,
        )

        f = Foo(d)
        @test f.x == "foo"
        @test f.y == DateTime(2018, 10, 8, 5, 20, 22, 782)
        @test f.z == 1234567890
        @test f.a == ["a", "b", "c"]
        @test f.b == 1
        @test f.c == 2

        d["b"] = nothing
        delete!(d, "c")

        f = Foo(d)
        @test f.b === nothing
        @test f.c === missing

        b = Bar(Dict("x" => 1))
        @test b.x == 1
    end
end
