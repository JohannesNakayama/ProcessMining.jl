function Base.filter(eventlog::EventLog, filter_function::Function, field::Symbol)
    filtered_eventlog = deepcopy(eventlog)
    trace_filter = map(filter_function, getproperty(filtered_eventlog, field))
    filtered_field = getproperty(filtered_eventlog, field)[trace_filter]
    setproperty!(filtered_eventlog, field, filtered_field)
    return filtered_eventlog
end

function Base.filter!(eventlog::EventLog, filter_function::Function, field::Symbol)
    eventlog = filter(eventlog, filter_function, field)
    return eventlog
end


# select

# group_by

# summarize
