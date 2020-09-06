# EXTRACT RELATIONS
# direct succession     >
# causality             ->
# parallel              ||
# choice                #

# FOOTPRINT MATRIX

# OUTLINE
# 1. Each activity corresponds to a transition in α(L)
# 2. Fix the set of start activities (first elements of each trace)
# 3. Fix the set of end activities (last elements of each trace)
# 4. Calculate pairs (A, B)
# 5. Delete non-maximal pairs (A, B)
# 6. Determine places p_(A, B) from pairs (A, B)
# 7. Determine the flow relation
# 8. Put everything together

eventlog

mutable struct Footprint{T}
    colnames::Array{T}
    rownames::Array{T}
    relation::Matrix{Symbol}
end

function extract_event_traces(eventlog::EventLog)
    return [
        [event.name for event in trace.events] for trace in eventlog.traces
    ]
end

function extract_start_activities(extracted_event_traces::AbstractArray)
    return unique([first(trace) for trace in extracted_event_traces])
end

function extract_end_activities(extracted_event_traces::AbstractArray)
    return unique([last(trace) for trace in extracted_event_traces])
end

function extract_activity_set(extracted_event_traces::AbstractArray)
    return unique(collect(Iterators.flatten(extracted_event_traces)))
end

function get_direct_succession_relation(extracted_event_traces)
    direct_succession_relation = Set([])
    for trace in extracted_event_traces
        for i in 1:length(trace)
            if !(i == length(trace))
                push!(direct_succession_relation, (trace[i], trace[i + 1]))
            end
        end
    end
    return direct_succession_relation
end

function get_causality_relation(direct_succession_relation)
    causality_relation = Set([])
    for tup in direct_succession_relation
        if !((tup[2], tup[1]) in direct_succession_relation)
            push!(causality_relation, tup)
        end
    end
    return causality_relation
end

function get_parallel_relation(direct_succession_relation)
    parallel_relation = Set([])
    for tup in direct_succession_relation
        if ((tup[2], tup[1]) in direct_succession_relation) && !((tup[2], tup[1]) in parallel_relation)
            push!(parallel_relation, tup)
        end
    end
    return parallel_relation
end

function get_choice_relation(direct_succession_relation, activity_set)
    all_pairs = Set([(a, b) for a in activity_set for b in activity_set])
    choice_relation = setdiff(all_pairs, direct_succession_relation)
    return choice_relation
end

Matrix{Symbol}(undef, 100, 100)

extracted_event_traces = extract_event_traces(eventlog)

start_activities = extract_start_activities(extracted_event_traces)
end_activities = extract_end_activities(extracted_event_traces)
activity_set = extract_activity_set(extracted_event_traces)

direct_succession_relation = get_direct_succession_relation(extracted_event_traces)
causality_relation = get_causality_relation(direct_succession_relation)
parallel_relation = get_parallel_relation(direct_succession_relation)
choice_relation = get_choice_relation(direct_succession_relation, activity_set)
