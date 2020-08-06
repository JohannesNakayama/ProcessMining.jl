mutable struct Event
    attributes::Dict{Any, Any}
end

mutable struct Trace
    metadata::Dict{Any, Any}
    events::Array{Event}
end

mutable struct EventLog
    global_event_attributes::Dict{Any, Any}
    global_trace_attributes::Dict{Any, Any}
    event_classifiers::Dict{Any, Any}
    traces::Array{Trace}
end
