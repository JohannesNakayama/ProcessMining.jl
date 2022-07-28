"""
    Event

An `Event` that can be part of a `Trace` in an `EventLog`.
"""
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


"""
    Trace

A `Trace` in an `EventLog` containing `Event`s.
"""
mutable struct Trace
    name::String
    id::Union{Int, AbstractString}
    metadata::Dict{Any, Any}
    events::Array{Event}
end


"""
    EventLog

An `EventLog` containing `Trace`s with `Event`s.
"""
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


Base.isless(t1::Trace, t2::Trace) = t1.name < t2.name
