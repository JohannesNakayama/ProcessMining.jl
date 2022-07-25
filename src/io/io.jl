function read_xes(path)
    xml_doc = EzXML.readxml(path)
    eventlog = eventlog_from_xml(xml_doc)
    return eventlog
end

function eventlog_from_xml(xml_doc)
    traces = extract_traces(xml_doc)
    event_classifiers = extract_event_classifiers(xml_doc)
    eventlog = EventLog(
        traces,
        event_classifiers
    )
    return eventlog
end

function extract_traces(xml_doc)
    namespace = get_namespace(xml_doc)
    xpath_expression = "./ns:trace"
    trace_nodes = EzXML.findall(
        xpath_expression,
        xml_doc.root,
        ["ns"=>namespace]
    )
    traces = [create_trace(t, namespace) for t in trace_nodes]
    return traces
end

function extract_event_classifiers(xml_doc)
    namespace = get_namespace(xml_doc)
    xpath_expression = "./ns:classifier"
    event_classifier_nodes = EzXML.findall(
        xpath_expression,
        xml_doc.root,
        ["ns"=>namespace]
    )
    event_classifiers = Dict()
    for node in event_classifier_nodes
        key = node["name"]
        value = node["keys"]
        event_classifiers[key] = value
    end
    return event_classifiers
end

function get_namespace(xml_doc)
    try
        return EzXML.namespace(xml_doc.root)
    catch Exception
        return DEFAULT_NAMESPACE
    end
end

function create_trace(trace_node, namespace)
    metadata = extract_metadata(trace_node)
    xpath_expression = "./ns:event"
    event_nodes = EzXML.findall(
        xpath_expression,
        trace_node,
        ["ns"=>namespace]
    )
    name = pop_or_na!(metadata, "concept:name")
    id = pop_or_na!(metadata, "identity:id")
    events = [create_event(e) for e in event_nodes]
    trace = Trace(name, id, metadata, events)
    return trace
end

function extract_metadata(trace_node)
    metadata_nodes = [
        node
        for node in EzXML.elements(trace_node)
        if node.name != "event"
    ]
    metadata = Dict()
    for node in metadata_nodes
        key = node["key"]
        value = node["value"]
        metadata[key] = value
    end
    return metadata
end

function create_event(event_node)
    event_attribute_nodes = EzXML.elements(event_node)
    event_attributes = Dict()
    for attribute in event_attribute_nodes
        key = attribute["key"]
        value = attribute["value"]
        event_attributes[key] = value
    end
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

# TODO: this seem pretty bad
function pop_or_na!(dict::Dict, key::String)
    try
        return pop!(dict, key)
    catch Exception
        return "NA"
    end
end

# TODO: add streaming option for large files
