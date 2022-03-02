mutable struct Event
    name::String
    timestamp::String
    id::String
    instance::String
    transition::String
    resource::String
    role::String
    group::String
    attributes::Dict{Any, Any}
end

mutable struct Trace
    name::String
    id::Union{Int, AbstractString}
    metadata::Dict{Any, Any}
    events::Array{Event}
end

mutable struct EventLog
    traces::Array{Trace}
    event_classifiers::Dict{Any, Any}
end

function Base.show(io::IO, ::MIME"text/plain", event::Event)
    print("Event \"$(event.name)\", logged at $(event.timestamp)")
end

function Base.show(io::IO, ::MIME"text/plain", trace::Trace)
    print("Trace \"$(trace.name)\" with $(length(trace.events)) events")
end

function Base.show(io::IO, ::MIME"text/plain", eventlog::EventLog)
    print("EventLog with $(length(eventlog.traces)) traces")
end
