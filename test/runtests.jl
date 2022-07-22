using ProcessMining
using Test

@testset "add_places!_test" begin
    pn = SimplePetriNet()
    add_places!(pn, [0, 0, 1, 0, 2, 0])
    @test length(pn.places) == 6
    @test pn.places[3].marking == 1
    @test pn.places[5].marking == 2
end

