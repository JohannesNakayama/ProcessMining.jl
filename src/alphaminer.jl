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

# OBJECTS FOR WORKFLOW
begin
    using ProcessMining
    eventlog = read_xes(joinpath("data", "Performance.xes"))
    eventlog2 = read_xes(joinpath("data", "road_fines.xes"))
end
# ------------------------

# MAYBE NOT NEEDED
# mutable struct Footprint{T}
#     colnames::Array{T}
#     rownames::Array{T}
#     relation::Matrix{Symbol}
# end
# ------------------------

# 1) GET RAW TRACES AND ACTIVITY SET FROM THE LOG
function extract_event_traces(eventlog::EventLog)
    return [
        [event.name for event in trace.events] for trace in eventlog.traces
    ]
end

function extract_activity_set(extracted_event_traces::AbstractArray)
    return unique(collect(Iterators.flatten(extracted_event_traces)))
end
# ------------------------

# 2 + 3) SIMPLE STEPS: START AND END ACTIVITIES
function extract_start_activities(extracted_event_traces::AbstractArray)
    return unique([first(trace) for trace in extracted_event_traces])
end

function extract_end_activities(extracted_event_traces::AbstractArray)
    return unique([last(trace) for trace in extracted_event_traces])
end
# ------------------------

# 4a) EXTRACT RELATIONS FROM THE ACTIVITY LOG
function extract_direct_succession_relation(extracted_event_traces)
    direct_succession_relation = Set(Tuple{String, String}[])
    for trace in extracted_event_traces
        for i in 1:length(trace)
            if !(i == length(trace))
                push!(direct_succession_relation, (trace[i], trace[i + 1]))
            end
        end
    end
    return direct_succession_relation
end

function extract_causality_relation(direct_succession_relation)
    causality_relation = Set(Tuple{String, String}[])
    for tup in direct_succession_relation
        if !((tup[2], tup[1]) in direct_succession_relation)
            push!(causality_relation, tup)
        end
    end
    return causality_relation
end

function extract_parallel_relation(direct_succession_relation)
    parallel_relation = Set(Tuple{String, String}[])
    for tup in direct_succession_relation
        if ((tup[2], tup[1]) in direct_succession_relation) && !((tup[2], tup[1]) in parallel_relation)
            push!(parallel_relation, tup)
        end
    end
    return parallel_relation
end

function extract_choice_relation(direct_succession_relation, activity_set)
    all_pairs = Set([(a, b) for a in activity_set for b in activity_set])
    choice_relation = setdiff(all_pairs, direct_succession_relation)
    return choice_relation
end
# ------------------------

# 4b) GET SET X_L
function extract_place_pairs(causality_relation, choice_relation)
    place_pairs = []
    for mapping in causality_relation
        push!(place_pairs, (Set([mapping[1]]), Set([mapping[2]])))
    end
    place_pairs = merge_append_sets!(place_pairs, choice_relation)
    return place_pairs
end

function merge_append_sets!(place_pairs, choice_relation)
    counter = 0
    for p1 in place_pairs
        for p2 in place_pairs
            if p1 != p2
                if is_unrelated(p1, p2, choice_relation)
                    print("pushed!\n")
                    place_pairs = push!(place_pairs, (union(p1[1], p2[1]), union(p1[2], p2[2])))
                    counter += 1
                end
            end
        end
    end
    if counter > 0
        place_pairs = merge_append_sets!(place_pairs, choice_relation)
    end
    return place_pairs
end

# !!!!KNACKPUNKT!!!!
function is_unrelated(p1, p2, choice_relation)
    is_unrelated_predecessor = (
        (issubset(p1[1], p2[1]) || issubset(p2[1], p1[1]))
        && (((first(p1[1]), first(p2[1])) in choice_relation) || ((first(p2[1]), first(p1[1])) in choice_relation))
    )
    is_unrelated_successor = (
        (issubset(p1[2], p2[2]) || issubset(p2[2], p1[2]))
        && (((first(p1[2]), first(p2[2])) in choice_relation) || ((first(p2[2]), first(p1[2])) in choice_relation))
    )
    return is_unrelated_predecessor && is_unrelated_successor
end
# ------------------------


# --------------------------- TESTING --------------------------- #

pp = extract_place_pairs(causality_relation, choice_relation)

merge_append_sets!(pp, choice_relation)

is_unrelated(pp[14], pp[16], choice_relation)



Matrix{Symbol}(undef, 100, 100)


# TESTING

begin
    extracted_event_traces = extract_event_traces(eventlog)
    start_activities = extract_start_activities(extracted_event_traces)
    end_activities = extract_end_activities(extracted_event_traces)
    activity_set = extract_activity_set(extracted_event_traces)
    direct_succession_relation = extract_direct_succession_relation(extracted_event_traces)
    causality_relation = extract_causality_relation(direct_succession_relation)
    parallel_relation = extract_parallel_relation(direct_succession_relation)
    choice_relation = extract_choice_relation(direct_succession_relation, activity_set)
end

begin
    extracted_event_traces = extract_event_traces(eventlog2)
    start_activities = extract_start_activities(extracted_event_traces)
    end_activities = extract_end_activities(extracted_event_traces)
    activity_set = extract_activity_set(extracted_event_traces)
    direct_succession_relation = extract_direct_succession_relation(extracted_event_traces)
    causality_relation = extract_causality_relation(direct_succession_relation)
    parallel_relation = extract_parallel_relation(direct_succession_relation)
    choice_relation = extract_choice_relation(direct_succession_relation, activity_set)
end
