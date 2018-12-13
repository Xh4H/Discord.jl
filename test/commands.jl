@testset "Commands" begin
    delete_handler!(c, MessageCreate)

    # Adding handlers adds to MessageCreate.
    add_command!(c, :foo, (c, m) -> nothing)
    @test haskey(c.handlers[MessageCreate], :foo)

    # We can delete commands with a shortcut.
    delete_command!(c, :foo)
    @test !haskey(c.handlers[MessageCreate], :foo)

    # TODO: Finish these tests.
end
