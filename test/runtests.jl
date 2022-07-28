using ProcessMining
using Test

@testset "add_places!_test" begin
    pn = PetriNet()
    markings = [0, 0, 1, 0, 2, 0]
    for m in markings
        add_place!(pn, marking = m)
    end
    @test length(pn.places) == 6
    @test pn.places[3].marking == 1
    @test pn.places[5].marking == 2
end


@testset "read_xes_test" begin
    eventlog = read_xes("running-example.xes")
    @test length(eventlog) == 6
    @test length(eventlog.traces[1].events) == 5
    @test eventlog.traces[4].events[2].name == "check ticket"
end
