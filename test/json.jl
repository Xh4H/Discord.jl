@testset "JSON" begin
    io = IOBuffer()
    val, e = readjson(io)
    @test val === nothing
    @test e isa Empty

    io = IOBuffer("{bad]")
    val, e = readjson(io)
    @test val === nothing
    @test e !== nothing

    io = IOBuffer("[1,2,3]")
    val, e = readjson(io)
    @test val == [1, 2, 3]
    @test e === nothing

    # writejson can throw.
    io = IOBuffer()
    @test_throws ArgumentError writejson(io, @__MODULE__)

    io = IOBuffer()
    writejson(io, [1, 2, 3])
    @test String(take!(io)) == "[1,2,3]"

    io = IOBuffer()
    d = Dict("foo" => 0, "bar" => [1, 2, 3])
    writejson(io, d)
    @test JSON.parse(String(take!(io))) == d

    # The try version just returns the exception and backtrace.
    io = IOBuffer()
    e, bt = trywritejson(io, @__MODULE__)
    @test e isa ArgumentError

    io = IOBuffer()
    e, bt = trywritejson(io, [1, 2, 3])
    @test e === nothing && bt === nothing
end
