@testset "Helpers" begin
    ch = DiscordChannel(; id="255", type=0, guild_id="1")
    r = Role(; id=0xff, name="foo")
    u = User(; id="255", username="foo")
    e1 = Emoji(; id="255", name="foo")
    e2 = Emoji(; id=nothing, name="foo")

    @testset "String mention" begin
        @test sprint(show, ch) == "<#255>"
        @test sprint(show, r) == "<@&255>"
        @test sprint(show, u) == "<@255>"
        @test sprint(show, e1) == "<:foo:255>"
        @test sprint(show, e2) == ":foo:"
        m = Member(u, "foo", [], now(), true, true)
        @test sprint(show, m) == "<@!255>"
        m = Member(u, nothing, [], now(), true, true)
        @test sprint(show, m) == sprint(show, u)
        m = Member(u, missing, [], now(), true, true)
        @test sprint(show, m) == sprint(show, u)
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
        @test chunks[2] == "```julia\n1 + 1\n```"

        # Chunks are separated by spaces.
        chunks = split_message(string(repeat('.', 1995), " foo bar baz"))
        @test length(chunks) == 2
        @test chunks[1] == string(repeat('.', 1995), " foo")
        @test chunks[2] == "bar baz"
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
