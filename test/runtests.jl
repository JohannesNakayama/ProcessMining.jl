using ProcessMining
using EzXML
using Test


# TODO:
#   use more different event logs for testing
#   comprehensive test spaces for all functions


# IO TESTS

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


@testset "extract_trace_metadata_test" begin
    xml_doc = EzXML.readxml("running-example.xes")
    ns = ProcessMining.get_namespace(xml_doc)
    xpath_expr = "./ns:trace"
    trace_nodes = EzXML.findall(xpath_expr, xml_doc.root, ["ns"=>ns])
    metadata_3 = ProcessMining.extract_trace_metadata(trace_nodes[3])
    metadata_5 = ProcessMining.extract_trace_metadata(trace_nodes[5])
    @test typeof(metadata_3) <: AbstractDict
    @test metadata_3["creator"] == "Fluxicon Nitro"
    @test metadata_5["concept:name"] == "5"
end


@testset "create_event_test" begin
    xml_doc = EzXML.readxml("running-example.xes")
    ns = ProcessMining.get_namespace(xml_doc)
    xpath_expr_trace = "./ns:trace"
    trace_nodes = EzXML.findall(xpath_expr_trace, xml_doc.root, ["ns"=>ns])
    xpath_expr_event = "./ns:event"
    event_nodes = EzXML.findall(xpath_expr_event, trace_nodes[1], ["ns"=>ns])
    event = ProcessMining.create_event(event_nodes[5])
    @test typeof(event) == Event
    @test event.name == "reinitiate request"
    @test typeof(event.attributes) <: AbstractDict
    @test event.attributes["Resource"] == "Sara"
    @test event.resource == "Sara"
end


@testset "pop_or_na!_test" begin
    testdict_1 = Dict(:a => 1, :b => 2)
    testdict_2 = Dict("c" => 5, "d" => 6, "e" => 7)
    @test ProcessMining.pop_or_na!(testdict_1, :a) == 1
    @test_throws KeyError testdict_1[:a]
    @test ProcessMining.pop_or_na!(testdict_2, "d") == 6
    @test_throws KeyError testdict_2["d"]
    @test testdict_2["e"] == 7
end



