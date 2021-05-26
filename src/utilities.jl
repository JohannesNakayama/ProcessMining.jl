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

function Base.filter(eventlog::EventLog, filter_function::Function, field::Symbol)
    filtered_eventlog = deepcopy(eventlog)
    trace_filter = map(filter_function, getproperty(filtered_eventlog, field))
    filtered_field = getproperty(filtered_eventlog, field)[trace_filter]
    setproperty!(filtered_eventlog, field, filtered_field)
    return filtered_eventlog
end

function Base.filter!(eventlog::EventLog, filter_function::Function, field::Symbol)
    trace_filter = map(filter_function, getproperty(eventlog, field))
    filtered_field = getproperty(eventlog, field)[trace_filter]
    setproperty!(eventlog, field, filtered_field)
    return eventlog
end