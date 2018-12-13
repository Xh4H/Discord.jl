# A test case which covers most possible field types.
@eval Discord struct Foo
    a::String
    b::DateTime
    c::Snowflake
    d::Vector{String}
    e::Union{Int, Nothing}
    f::Union{Int, Missing}
    g::Union{Vector{String}, Nothing, Missing}
    h::Union{Foo, Missing}
    abcdefghij::Union{Int, Missing}  # 10 characters.
end
@eval Discord @boilerplate Foo :constructors :docs :lower :merge :mock

# A simple struct with merge.
@eval Discord struct Bar
    id::Int
    x::Int
    y::Union{Int, Missing}
end
@eval Discord @boilerplate Bar :merge

using Discord: Foo, Bar

@testset "Boilerplate" begin
    local f
    kwargs = Dict(
        :a => "foo",
        :b => "2018-10-08T05:20:22.782Z",
        :c => "1234567890",
        :d => ["a", "b", "c"],
        :e => 1,
        :f => 2,
        :g => ["a", "b", "c"],
    )
    kwargs[:h] = copy(kwargs)

    @testset "@constructors" begin
        f = Foo(; kwargs...)
        @test f.a == Foo(kwargs).a
        @test f.a == "foo"
        @test f.b == DateTime(2018, 10, 8, 5, 20, 22, 782)
        @test f.c == 1234567890
        @test f.d == ["a", "b", "c"]
        @test f.e == 1
        @test f.f == 2
        @test f.g == ["a", "b", "c"]
        @test f.h isa Foo && f.h.a == "foo"

        # Set e to nothing, f and g to missing.
        kwargs[:e] = nothing
        delete!(kwargs, :f)
        delete!(kwargs, :g)
        f = Foo(; kwargs...)
        @test f.e === nothing
        @test ismissing(f.f)
        @test ismissing(f.g)

        # Union{T, Nothing, Missing} works too.
        kwargs[:g] = nothing
        f = Foo(; kwargs...)
        @test f.g === nothing
    end

    @testset "@docs" begin
        docs = string(@doc Foo)
        # Variable names get padded to the longest one.
        @test occursin("$(rpad("a", 10)) :: String", docs)
        # Array{T,1} is replaced with Vector{T}.
        @test occursin("Vector{String}", docs)
        # Union{Missing, Nothing, T} is replaced with Union{T, Missing, Nothing}.
        @test_broken occursin("Union{Vector{String}, Missing, Nothing}", docs)
        # Union{Missing, T} is replaced with Union{T, Missing}.
        @test_broken occursin("Union{Int, Missing}", docs)
        # Union{Nothing, T} is replaced with Union{T, Nothing}.
        @test_broken occursin("Union{Int, Nothing}", docs)
    end

    @testset "@lower" begin
        kwargs[:b] = kwargs[:h][:b] = round(Int, datetime2unix(f.b))
        kwargs[:c] = kwargs[:h][:c] = snowflake(f.c)
        lowered = JSON.lower(f)
        # The result is always a Dict{Symbol, Any}.
        @test lowered isa Dict{Symbol, Any}
        @test lowered == Dict(
            :a => "foo",
            :b => kwargs[:b],
            :c => kwargs[:c],
            :d => ["a", "b", "c"],
            :e => nothing,
            :g => nothing,
            :h => kwargs[:h],
        )
    end

    @testset "@merge" begin
        # Anything except missing values should be taken from f2.
        f2 = Foo("bar", f.b, f.c, f.d, f.e, f.f, f.g, missing, missing)
        f3 = merge(f, f2)
        @test f3.a == f2.a
        @test f3.h == f.h
    end

    @testset "@mock" begin
        # Just make sure this doesn't error, it should cover most types.
        foreach(mock, subtypes(AbstractEvent))

        # We can also specify fields via keywords.
        m = mock(Message; content="foo")
        @test m.content == "foo"
    end
end
