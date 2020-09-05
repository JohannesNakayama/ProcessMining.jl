using ProcessMining

eventlog = read_xes(joinpath("data", "Performance.xes"))
eventlog2 = read_xes(joinpath("data", "RepairExample.xes"))

length(eventlog)
length(eventlog.traces[1])
info(eventlog)

eventlog
eventlog.traces[1]
eventlog.traces[1].events[1]

filter(eventlog, x -> x.name == "173688", :traces)
filter!(eventlog, x -> x.name == "173688", :traces)
length(eventlog)
