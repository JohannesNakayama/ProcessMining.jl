function info(eventlog::EventLog)
    n_traces = length(eventlog.traces)
    print("EventLog with $n_traces traces.")
end

Base.length(eventlog::EventLog) = length(eventlog.traces)
