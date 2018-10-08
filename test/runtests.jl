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

        b = Bar(Dict("a" => 1))
        @test b.a == 1
    end
end
