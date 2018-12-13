@eval Discord struct Baz
    id::Int
    x::Int
    y::Union{Int, Missing}
end
@eval Discord @boilerplate Baz :merge
using Discord: Baz

@testset "State" begin
    @testset "insert_or_update!" begin
        d = Dict()
        v = Baz[]

        # Inserting a new entry works fine.
        b = Baz(1, 2, 3)
        insert_or_update!(d, b.id, b)
        @test d[b.id] == b
        # But when we insert a value with the same ID, it's merged.
        b = Baz(1, 3, 3)
        insert_or_update!(d, b.id, b)
        @test d[b.id] == b
        b = Baz(1, 10, missing)
        insert_or_update!(d, b.id, b)
        @test d[b.id] == Baz(b.id, b.x, 3)

        # We can also insert/update without specifying the key, :id is inferred.
        b = Baz(2, 2, 1)
        insert_or_update!(d, b)
        @test d[b.id] == b
        b = Baz(2, 1, missing)
        insert_or_update!(d, b)
        @test d[b.id] == Baz(b.id, b.x, 1)

        # We can also do this on lists.
        b = Baz(1, 2, 3)
        insert_or_update!(v, b.id, b)
        @test length(v) == 1 && first(v) == b
        b = Baz(1, 10, missing)
        insert_or_update!(v, b.id, b)
        @test length(v) == 1 && first(v) == Baz(b.id, b.x, 3)
        b = Baz(1, 2, 2)
        insert_or_update!(v, b)
        @test length(v) == 1 && first(v) == b

        # If we need something fancier to index into a list, we can use a key function.
        b = Baz(1, 4, 5)
        insert_or_update!(v, b.id, b; key=x -> x.y)
        # We inserted a new element because we looked for an element with y == b.id.
        @test length(v) == 2 && last(v) == b
        # If we leave out the insert key, the key function is used on the value too.
        b = Baz(1, 0, 5)
        # We updated the value with y == b.y.
        insert_or_update!(v, b; key=x -> x.y)
        @test length(v) == 2 && last(v) == b

        # The updated value is returned.
        empty!(d)
        empty!(v)
        b = Baz(1, 2, 3)
        @test insert_or_update!(d, b) == b
        @test insert_or_update!(v, b) == b
        b = Baz(1, 3, missing)
        @test insert_or_update!(d, b) == Baz(1, 3, 3)
        @test insert_or_update!(v, b) == Baz(1, 3, 3)
    end
end
