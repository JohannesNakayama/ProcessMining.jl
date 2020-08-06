function read_xes(path)
    xml_doc = EzXML.readxml(path)
    eventlog = create_eventlog(xml_doc)
    return eventlog
end

function create_eventlog(xml_doc)
    global_event_attributes = extract_global_attributes(xml_doc, "event")
    global_trace_attributes = extract_global_attributes(xml_doc, "trace")
    event_classifiers = extract_event_classifiers(xml_doc)
    traces = extract_traces(xml_doc)
    eventlog = EventLog(
        global_event_attributes,
        global_trace_attributes,
        event_classifiers,
        traces
    )
    return eventlog
end

function extract_global_attributes(xml_doc, scope)
    namespace = EzXML.namespace(xml_doc.root)
    xpath_expression = "./ns:global[@scope='" * scope * "']/*"
    global_attribute_nodes = EzXML.findall(
        xpath_expression,
        xml_doc.root,
        ["ns"=>namespace]
    )
    global_attributes = Dict()
    for node in global_attribute_nodes
        key = node["key"]
        value = node["value"]
        global_attributes[key] = value
    end
    return global_attributes
end

function extract_event_classifiers(xml_doc)
    namespace = EzXML.namespace(xml_doc.root)
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

function extract_traces(xml_doc)
    namespace = EzXML.namespace(xml_doc.root)
    xpath_expression = "./ns:trace"
    trace_nodes = EzXML.findall(
        xpath_expression,
        xml_doc.root,
        ["ns"=>namespace]
    )
    traces = [create_trace(t, namespace) for t in trace_nodes]
    return traces
end

function create_trace(trace_node, namespace)
    metadata = extract_metadata(trace_node)
    xpath_expression = "./ns:event"
    event_nodes = EzXML.findall(
        xpath_expression,
        trace_node,
        ["ns"=>namespace]
    )
    events = [create_event(e) for e in event_nodes]
    trace = Trace(metadata, events)
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
    event = Event(event_attributes)
    return event
end

# NOTE: add streaming option for large files
