function info(eventlog::EventLog)
    n_traces = length(eventlog.traces)
    if n_traces == 1
        infotext = "EventLog with " * string(n_traces) * " trace."
    else
        infotext = "EventLog with " * string(n_traces) * " traces."
    end
    print(infotext)
    return infotext
end

Base.length(eventlog::EventLog) = length(eventlog.traces)

Base.length(trace::Trace) = length(trace.events)
