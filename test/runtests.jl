using Julicord
using Test

@testset "Julicord" begin
    c = Client("token")
    @test c.token == "Bot token"
    c = Client("Bot token")
    @test c.token == "Bot token"
end
