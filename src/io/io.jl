"""
    read_xes(path::String)

Read an eventlog file in xes format.

# Example

The return value is an `EventLog` object.

```julia-repl
julia>read_xes("my-eventlog.xes")
EventLog with 6 traces
```

See also [`EventLog`](@ref)
"""
function read_xes(path::String)
    xml_doc = EzXML.readxml(path)
    eventlog = eventlog_from_xml(xml_doc)
    return eventlog
end


"""
    ProcessMining.eventlog_from_xml(xml_doc::EzXML.Document)

Turn an XML document in `EzXML.Document` format into an `EventLog`.

# Example

The function is not exported since `read_xes` should be used from the public API.
For development, the function can be accessed via `ProcessMining.eventlog_from_xml`.

```julia-repl
julia>xml_doc = EzXML.readxml("my-eventlog.xes")
EzXML.Document(EzXML.Node(<DOCUMENT_NODE@0x0000000002ca12b0>))

julia>ProcessMining.eventlog_from_xml(xml_doc)
EventLog with 6 traces
```
"""
function eventlog_from_xml(xml_doc::EzXML.Document)
    traces = extract_traces(xml_doc)
    event_classifiers = extract_event_classifiers(xml_doc)
    eventlog = EventLog(traces, event_classifiers)
    return eventlog
end


"""
    ProcessMining.extract_traces(xml_doc::EzXML.Document)

Extract event `Trace`s from an `EzXML.Document`.

# Example

The function is not exported since `read_xes` should be used from the public API.
For development, the function can be accessed via `ProcessMining.extract_traces`.

```julia-repl
julia>xml_doc = EzXML.readxml("my-eventlog.xes")
EzXML.Document(EzXML.Node(<DOCUMENT_NODE@0x0000000002ca12b0>))

julia>ProcessMining.extract_traces(xml_doc)
6-element Vector{Trace}:
 Trace "3" with 9 events
 Trace "2" with 5 events
 Trace "1" with 5 events
 Trace "6" with 5 events
 Trace "5" with 13 events
 Trace "4" with 5 events
```
"""
function extract_traces(xml_doc::EzXML.Document)
    ns = get_namespace(xml_doc)
    xpath_expr = "./ns:trace"
    trace_nodes = EzXML.findall(xpath_expr, xml_doc.root, ["ns"=>ns])
    traces = sort([create_trace(t, ns) for t in trace_nodes])
    return traces
end


"""
    ProcessMining.extract_event_classifiers(xml_doc::EzXML.Document)

Extract event classifiers from `EzXML.Document`.

# Example

```julia-repl
julia>xml_doc = EzXML.readxml("my-eventlog.xes")
EzXML.Document(EzXML.Node(<DOCUMENT_NODE@0x0000000002ca12b0>))

julia>ProcessMining.extract_event_classifiers(xml_doc)
Dict{Any, Any} with 2 entries:
  "Activity"            => "Activity"
  "activity classifier" => "Activity"
```
"""
function extract_event_classifiers(xml_doc::EzXML.Document)
    ns = get_namespace(xml_doc)
    xpath_expr = "./ns:classifier"
    event_classifier_nodes = EzXML.findall(xpath_expr, xml_doc.root, ["ns"=>ns])
    event_classifiers = Dict(
        node["name"] => node["keys"]
        for node in event_classifier_nodes
    )
    return event_classifiers
end


"""
    get_namespace(xml_doc::EzXML.Document)

Get namespace of an `EzXML.Document` or, if not available, return default xes namespace.

Default namespace is "http://www.xes-standard.org/".
"""
function get_namespace(xml_doc::EzXML.Document)
    try
        return EzXML.namespace(xml_doc.root)
    catch Exception
        return DEFAULT_NAMESPACE
    end
end


"""
    ProcessMining.create_trace(trace_node::EzXML.Node, ns::String)

Create a `Trace` from an extracted trace `EzXML.Node` and a namespace.
"""
function create_trace(trace_node::EzXML.Node, ns::String)
    metadata = extract_trace_metadata(trace_node)
    xpath_expr = "./ns:event"
    event_nodes = EzXML.findall(xpath_expr, trace_node, ["ns"=>ns])
    name = pop_or_na!(metadata, "concept:name")
    id = pop_or_na!(metadata, "identity:id")
    events = [create_event(e) for e in event_nodes]
    trace = Trace(name, id, metadata, events)
    return trace
end


"""
    extract_trace_metadata(trace_node::EzXML.Node)
"""
function extract_trace_metadata(trace_node::EzXML.Node)
    metadata_nodes = [
        node
        for node in EzXML.elements(trace_node)
        if node.name != "event"
    ]
    metadata = Dict(
        node["key"] => node["value"]
        for node in metadata_nodes
    )
    return metadata
end


"""
    create_event(event_node::EzXML.Node)

Create an `Event` from an `EzXML.Node`.
"""
function create_event(event_node::EzXML.Node)
    event_attribute_nodes = EzXML.elements(event_node)
    event_attributes = Dict(
        node["key"] => node["value"]
        for node in event_attribute_nodes
    )
    name = pop_or_na!(event_attributes, "concept:name")
    timestamp = pop_or_na!(event_attributes, "time:timestamp")
    id = pop_or_na!(event_attributes, "identity:id")
    instance = pop_or_na!(event_attributes, "concept:instance")
    transition = pop_or_na!(event_attributes, "lifecycle:transition")
    resource = pop_or_na!(event_attributes, "org:resource")
    role = pop_or_na!(event_attributes, "org:role")
    group = pop_or_na!(event_attributes, "org:group")
    event = Event(
        name, timestamp, id,
        instance, transition,
        resource, role, group,
        event_attributes
    )
    return event
end


# TODO: this seems pretty bad
"""
    pop_or_na!(dict::Dict, key::String)

Pop item at key `key` from `Dict` or return "NA" if `key` doesn't exist.
"""
function pop_or_na!(dict::Dict, key::String)
    try
        return pop!(dict, key)
    catch Exception
        return "NA"
    end
end


# TODO: add streaming option for large files
