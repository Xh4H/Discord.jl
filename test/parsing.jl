@testset "Parsing" begin
    @testset "tryparse" begin
        @test tryparse(c, Int, 123) == (123, nothing)
        @test tryparse(c, Vector{UInt16}, Int[1, 2, 3]) == (UInt16[1, 2, 3], nothing)
        val, e = @test_logs (:error, r"Parsing failed") tryparse(c, Int, Dict())
        @test val === nothing
        @test e isa MethodError
    end

    @testset "Snowflake" begin
        # Snowflakes usually come in as strings.
        s = snowflake(string(typemax(UInt64)))
        @test isa(s, Snowflake)
        # Snowflake === UInt64.
        @test s == typemax(UInt64)

        # https://discordapp.com/developers/docs/reference#snowflakes-snowflake-id-format-structure-left-to-right
        s = Snowflake(0x06ecefa78e42000c)
        @test snowflake2datetime(s) == DateTime(2018, 10, 9, 1, 55, 31, 1)
        @test worker_id(s) == 0x01
        @test process_id(s) == 0x00
        @test increment(s) == 0x0c
    end

    @testset "DateTime" begin
        # Discord sends dates in some weird, inconsistent ways.
        d = datetime("2018-10-08T05:20:22.782643+00:00")
        @test d == DateTime(2018, 10, 8, 5, 20, 22, 782)
        d = datetime("2018-10-08T05:20:22.782Z")
        @test d == DateTime(2018, 10, 8, 5, 20, 22, 782)

        # But sometimes they also send nice millisecond Unix timestamps.
        d = datetime(1541288588543)
        @test d == DateTime(2018, 11, 3, 23, 43, 08, 543)
    end
end
