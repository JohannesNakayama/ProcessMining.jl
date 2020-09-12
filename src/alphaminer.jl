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

# ------------------------

# MAYBE NOT NEEDED
# mutable struct Footprint{T}
#     colnames::Array{T}
#     rownames::Array{T}
#     relation::Matrix{Symbol}
# end
# ------------------------


using ProcessMining
using Pipe

# 1) GET RAW TRACES AND ACTIVITY SET FROM THE LOG
function extract_event_traces(eventlog::EventLog)
    return [
        [event.name for event in trace.events] for trace in eventlog.traces
    ]
end

function extract_activity_set(extracted_event_traces::AbstractArray)
    activity_set = extracted_event_traces |>
        Iterators.flatten |>
        collect |>
        unique
    return activity_set
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
        if !(tup in parallel_relation) && ((tup[2], tup[1]) in direct_succession_relation)
            push!(parallel_relation, tup)
            push!(parallel_relation, (tup[2], tup[1]))
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
function iteratively_build_x(causality_relation, choice_relation)
    place_pairs = get_initial_place_pairs(causality_relation)
    while true
        size = length(place_pairs)
        build_place_pairs!(place_pairs, choice_relation, "forward")
        build_place_pairs!(place_pairs, choice_relation, "backward")
        new_size = length(place_pairs)
        if size == new_size
            break
        end
    end
    return place_pairs
end

function get_initial_place_pairs(causality_relation)
    place_pairs = Set([])
    for mapping in causality_relation
        push!(place_pairs, (Set([mapping[1]]), Set([mapping[2]])))
    end
    return place_pairs
end

function build_place_pairs!(place_pairs, choice_relation, mode::String)
    if mode == "forward"
        a = 1
        b = 2
    elseif mode == "backward"
        a = 2
        b = 1
    end
    place_pairs_addition = Set([])
    for p1 in place_pairs
        for p2 in place_pairs
            if p1 != p2 && (p1[a] == p2[a])
                combinations = get_combinations(p1, p2, b)
                flag = all_combinations_unrelated(combinations, choice_relation)
                if flag && (mode == "forward")
                    push!(place_pairs_addition, (p1[a], union(p1[b], p2[b])))
                elseif flag && (mode == "backward")
                    push!(place_pairs_addition, (union(p1[b], p2[b]), p1[a]))
                end
            end
        end
    end
    union!(place_pairs, place_pairs_addition)
    return place_pairs
end

function get_combinations(p1, p2, b)
    combinations = []
    for elem_p1 in collect(p1[b])
        for elem_p2 in collect(p2[b])
            push!(combinations, (elem_p1, elem_p2))
        end
    end
    return combinations
end

function all_combinations_unrelated(combinations, choice_relation)
    for comb in combinations
        if !(comb in choice_relation)
            return false
        end
    end
    return true
end
# ------------------------


# --------------------------- TESTING --------------------------- #
begin
    EVENT_LOG_FILE = "road_fines.xes"  # alternative: Performance.xes
    eventlog = read_xes(joinpath("data", EVENT_LOG_FILE))
    extracted_event_traces = extract_event_traces(eventlog)
    start_activities = extract_start_activities(extracted_event_traces)
    end_activities = extract_end_activities(extracted_event_traces)
    activity_set = extract_activity_set(extracted_event_traces)
    direct_succession_relation = extract_direct_succession_relation(extracted_event_traces)
    causality_relation = extract_causality_relation(direct_succession_relation)
    parallel_relation = extract_parallel_relation(direct_succession_relation)
    choice_relation = extract_choice_relation(direct_succession_relation, activity_set)
    X = iteratively_build_x(causality_relation, choice_relation)
end
