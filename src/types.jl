mutable struct Event
    name::String
    timestamp::Union{Date, String}
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
