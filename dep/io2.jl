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
