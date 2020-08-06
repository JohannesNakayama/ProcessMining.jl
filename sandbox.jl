using ProcessMining

eventlog = read_xes(joinpath("data", "Performance.xes"))

length(eventlog)
length(eventlog.traces[1])
info(eventlog)
