@testset "Helpers" begin
    ch = DiscordChannel(; id="255", type=0, guild_id="1")
    r = Role(; id=0xff, name="foo")
    u = User(; id="255", username="foo")
    e1 = Emoji(; id="255", name="foo")
    e2 = Emoji(; id=nothing, name="foo")

    @testset "String representations" begin
        @test string(ch) == "<#255>"
        @test string(r) == "<@&255>"
        @test string(u) == "<@255>"
        @test string(e1) == "<:foo:255>"
        @test string(e2) == "foo"
        m = Member(u, "foo", [], now(), missing, true, true)
        @test string(m) == "<@!255>"
        m = Member(u, nothing, [], now(), missing, true, true)
        @test string(m) == string(u)
        m = Member(u, missing, [], now(), missing, true, true)
        @test string(m) == string(u)
        # Make sure that string interpolation works normally (julia#21982).
        @test "$u" == string(u)
        @test "foo $u bar" == "foo " * string(u) * " bar"
    end

    @testset "split_message" begin
        # A vector is returned even if no splitting happens.
        chunks = split_message("foo")
        @test chunks == String["foo"]

        # Formatting is preserved between chunks.
        chunks = split_message(string(repeat('.', 1995), "**foobar**"))
        @test length(chunks) == 2
        @test chunks[2] == "**foobar**"
        chunks = split_message(string(repeat('.', 1995), "```julia\n1 + 1\n```"))
        @test length(chunks) == 2
        @test chunks[2] == "```julia\n1 + 1\n```"

        # Chunks are separated by spaces.
        chunks = split_message(string(repeat('.', 1995), " foo bar baz"))
        @test length(chunks) == 2
        @test chunks[1] == string(repeat('.', 1995), " foo")
        @test chunks[2] == "bar baz"

        # Chunks do not break down on nested formattings
        chunks = split_message(string(repeat('.', 3985), "**foo __bar__ baz**"))
        @test length(chunks) == 3
        @test chunks[3] == "**foo __bar__ baz**"

        # Chunks can vary in length limit
        chunks = split_message("**hello**, *world*", chunk_limit=10)
        @test length(chunks) == 2
        @test chunks[1] == "**hello**,"
        @test chunks[2] == "*world*"
        
        # Chunks can vary in length limit and still do not break down on nested formattings
        chunks = split_message("**hello**, _*beautiful* **blue**  world_", chunk_limit=25)
        @test length(chunks) == 2
        @test chunks[1] == "**hello**,"
        @test chunks[2] == "_*beautiful* **blue**  world_"

        # Chunks respect unicode
        chunks = split_message("**≡Ηϵλλo** *ωoρλδ≡*", chunk_limit=15)
        @test length(chunks) == 2
        @test chunks[1] == "**≡Ηϵλλo**"
        @test chunks[2] == "*ωoρλδ≡*"       
        chunks = split_message("Examples\n≡≡≡≡≡≡≡≡\n```julia\njulia> x=1\n1\n```\n", chunk_limit=12)
        @test length(chunks) == 3
        @test chunks[1] == "Examples\n≡≡≡"
        @test chunks[2] == "≡≡≡≡≡"
        @test chunks[3] ==  "```julia\njulia> x=1\n1\n```"

        # Chunks respect extra formatting
        chunks = split_message("Examples\n≡≡≡≡≡≡≡≡\n```julia\njulia> x=1\n1\n```\n", chunk_limit=12, extrastyles = [r"\n≡.+\n", r"n-.+\n"])
        @test length(chunks) == 3
        @test chunks[1] == "Examples"
        @test chunks[2] == "≡≡≡≡≡≡≡≡"
        @test chunks[3] == "```julia\njulia> x=1\n1\n```"
    end

    @testset "plaintext" begin
        msg = Message(;
            id="1",
            channel_id="1",
            content="<@255> <@!255>",
            mentions=[JSON.lower(u)],
        )
        @test plaintext(msg) == "@foo @foo"
    end

    @testset "@fetch/@fetchval" begin
        @testset "wrapfn!" begin
            ex = :(foo(1, 2, 3))

            # Calls to the designated functions get wrapped in another function.
            @test wrapfn!(ex, (:foo,), :bar) == :($(esc(:bar))($(esc(:(foo(1, 2, 3))))))
            # But only if we specify that function to be wrapped.
            @test wrapfn!(ex, (:baz,), :bar) == ex

            ex = :(x = foo(1))
            expected = :($(esc(:x)) = $(esc(:baz))($(esc(:(foo(1))))))

            # The function operates recursively.
            @test wrapfn!(ex, (:foo,), :baz) == expected
        end

        @testset "validate_fetch" begin
            @test_throws ArgumentError validate_fetch(:foo, :(begin end))
            @test_throws ArgumentError validate_fetch(:create, :foo, :(begin end))
            @test_throws ArgumentError validate_fetch(:create, :(x = 1))
            @test_throws ArgumentError validate_fetch(:create, :retrieve)
            validate_fetch(:create, :(begin end))
        end
    end
end
