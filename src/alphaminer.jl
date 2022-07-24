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

# TRADE-OFF:
#   redundancy of computations vs. understandability of the code
#   there are many "in-between" data structures that might be confusing
#       if there were structs for them, but if we recompute them over and
#       over, this might become a performance issue
#   should be reevaluated when the algorithm works!
# ------------------------


using ProcessMining
using Chain
using Combinatorics


# 1) GET RAW TRACES AND ACTIVITY SET FROM THE LOG
# 2 + 3) SIMPLE STEPS: START AND END ACTIVITIES
# 4a) EXTRACT RELATIONS FROM THE ACTIVITY LOG
# 4b) GET SET X_L


function get_raw_traces(eventlog::EventLog)
    return [
        [event.name for event in trace.events]
        for trace in eventlog.traces
    ]
end


function get_activities(eventlog::EventLog)
    return @chain eventlog begin
        get_raw_traces
        Iterators.flatten
        collect
        unique
    end
end


function get_direct_succession_relation(eventlog::EventLog)
    traces = get_raw_traces(eventlog)
    pairs = Set{Tuple{String, String}}()
    for trace in traces
        for i in 1:length(trace)
            if !(i == length(trace))
                push!(pairs, (trace[i], trace[i + 1]))
            end
        end
    end
    return pairs
end


function get_causality_relation(eventlog::EventLog)
    direct_succession = get_direct_succession_relation(eventlog)
    pairs = Set{Tuple{String, String}}()
    for pair in direct_succession
        if !(reverse(pair) in direct_succession)
            push!(pairs, pair)
        end
    end
    return pairs
end


function get_parallel_relation(eventlog::EventLog)
    direct_succession = get_direct_succession_relation(eventlog)
    pairs = Set{Tuple{String, String}}()
    for pair in direct_succession
        if reverse(pair) in direct_succession
            push!(pairs, pair)
            push!(pairs, reverse(pair))
        end
    end
    return pairs
end


function get_choice_relation(eventlog::EventLog)
    activities = get_activities(eventlog)
    direct_succession = get_direct_succession_relation(eventlog)
    choice_complement = Set{Tuple{String, String}}()
    for d in direct_succession
        push!(choice_complement, d)
        push!(choice_complement, reverse(d))
    end
    allpairs = Set([(a, b) for a in activities for b in activities])
    pairs = setdiff(allpairs, choice_complement)
    return pairs
end


function extract_start_activities(eventlog::EventLog)
    activity_traces = extract_activity_traces(eventlog)
    return unique([first(trace) for trace in activity_traces])
end


function extract_end_activities(eventlog::EventLog)
    activity_traces = extract_activity_traces(eventlog)
    return unique([last(trace) for trace in activity_traces])
end







function mine_all_place_pairs(eventlog::EventLog)
    activity_traces = extract_activity_traces(eventlog)
    activity_set = extract_activity_set(eventlog)
    direct_succession = DirectSuccessionRelation(eventlog)
    causality = CausalityRelation(eventlog)
    parallel = ParallelRelation(eventlog)
    choice = ChoiceRelation(eventlog)
    # THIS WILL CERTAINLY NOT WORK (COMBINATORIC EXPLOSION)!
    #   THERE HAS TO BE AN ITERATIVE WAY WITH A STOP CRITERIUM,
    #   BUT A BETTER ONE THAN THE PREVIOUS APPROACH IMPLEMENTED
    #   IN `iteratively_build_x`
    # activity_powerset = powerset(activity_set, 1)
    # place_set = Set()  # X_l
    # for a in activity_powerset
    #     for b in activity_powerset
    #         print(a, b)
    #     end
    # end
end


# function iteratively_build_x(causality_relation, choice_relation)
#     place_pairs = get_initial_place_pairs(causality_relation)
#     while true
#         size = length(place_pairs)
#         build_place_pairs!(place_pairs, choice_relation, "forward")
#         build_place_pairs!(place_pairs, choice_relation, "backward")
#         new_size = length(place_pairs)
#         if size == new_size
#             break
#         end
#     end
#     return place_pairs
# end

# function get_initial_place_pairs(causality_relation)
#     place_pairs = Set([])
#     for mapping in causality_relation
#         push!(place_pairs, (Set([mapping[1]]), Set([mapping[2]])))
#     end
#     return place_pairs
# end

# function build_place_pairs!(place_pairs, choice_relation, mode::String)
#     if mode == "forward"
#         a = 1
#         b = 2
#     elseif mode == "backward"
#         a = 2
#         b = 1
#     end
#     place_pairs_addition = Set([])
#     for p1 in place_pairs
#         for p2 in place_pairs
#             if p1 != p2 && (p1[a] == p2[a])
#                 combinations = get_combinations(p1, p2, b)
#                 flag = all_combinations_unrelated(combinations, choice_relation)
#                 if flag && (mode == "forward")
#                     push!(place_pairs_addition, (p1[a], union(p1[b], p2[b])))
#                 elseif flag && (mode == "backward")
#                     push!(place_pairs_addition, (union(p1[b], p2[b]), p1[a]))
#                 end
#             end
#         end
#     end
#     union!(place_pairs, place_pairs_addition)
#     return place_pairs
# end

# function get_combinations(p1, p2, b)
#     combinations = []
#     for elem_p1 in collect(p1[b])
#         for elem_p2 in collect(p2[b])
#             push!(combinations, (elem_p1, elem_p2))
#         end
#     end
#     return combinations
# end

# function all_combinations_unrelated(combinations, choice_relation)
#     for comb in combinations
#         if !(comb in choice_relation)
#             return false
#         end
#     end
#     return true
# end
# # ------------------------



# --------------------------- TESTING --------------------------- #
begin
    eventlog = read_xes(joinpath("data", "running-example.xes"))
    extracted_activity_traces = extract_activity_traces(eventlog)
    start_activities = extract_start_activities(eventlog)
    end_activities = extract_end_activities(eventlog)
    activity_set = extract_activity_set(eventlog)

    all_pairs_iterator = Iterators.product(activity_set, activity_set)

    direct_succession_relation = extract_direct_succession_relation(extracted_activity_traces)
    causality_relation = extract_causality_relation(direct_succession_relation)
    parallel_relation = extract_parallel_relation(direct_succession_relation)
    choice_relation = extract_choice_relation(direct_succession_relation, activity_set)
    X = iteratively_build_x(causality_relation, choice_relation)
end
