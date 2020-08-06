using EzXML

include(joinpath("src", "io.jl"))

path = joinpath("data", "Trace_ABCD.xes")
read_xes(path)



eventlog = read_xes(joinpath("data", "Alignment_EventLog.xes"))
eventlog

xes_log = readxml(joinpath("data", "Performance.xes"))
event_log_root = xes_log.root
event_log_nodes = elements(event_log_root)



# create xml document
doc = XMLDocument()

# create xml element
elem = ElementNode("root")

# set created element as document root node
setroot!(doc, elem)

# create a text element
txt = TextNode("blablabla")

# add text to root node
link!(elem, txt)

print(doc)

elem.type
elem.name
elem.path
elem.content
elem.namespace === nothing
elem.name = "ELEMENT"
elem.content = "SOME BETTER TEXT!"
print(doc)

txt.type
txt.name
txt.path
txt.content
txt.namespace === nothing
