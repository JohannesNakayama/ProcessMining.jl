using ProcessMining
using EzXML
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


@testset "eventlog_from_xml_test" begin
    xml_doc = EzXML.readxml("running-example.xes")
    eventlog = ProcessMining.eventlog_from_xml(xml_doc)
    @test length(eventlog) == 6
    @test length(eventlog.traces[2].events) == 5
    @test eventlog.traces[5].events[2].name == "examine casually"
end


@testset "extract_traces_test" begin
    xml_doc = EzXML.readxml("running-example.xes")
    traces = ProcessMining.extract_traces(xml_doc)
    @test traces[1].name == "1"
    @test length(traces[3].events) == 9
    @test traces[6].events[2].name == "examine casually"
end


@testset "extract_event_classifiers_test" begin
    xml_doc = EzXML.readxml("running-example.xes")
    event_classifiers = ProcessMining.extract_event_classifiers(xml_doc)
    @test "Activity" in keys(event_classifiers)    
    @test "activity classifier" in keys(event_classifiers)
    @test event_classifiers["Activity"] == "Activity"
    @test event_classifiers["activity classifier"] == "Activity"
end


@testset "get_namespace_test" begin
    xml_doc = EzXML.readxml("running-example.xes")
    ns = ProcessMining.get_namespace(xml_doc)
    @test ns == "http://code.deckfour.org/xes"
end


@testset "create_trace_test" begin
    xml_doc = EzXML.readxml("running-example.xes")
    ns = ProcessMining.get_namespace(xml_doc)
    xpath_expr = "./ns:trace"
    trace_nodes = EzXML.findall(xpath_expr, xml_doc.root, ["ns"=>ns])
    trace_1 = ProcessMining.create_trace(trace_nodes[1], ns)
    @test trace_1.name == "3"
    @test length(trace_1) == 9
end






