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
    raw_traces = get_raw_traces(eventlog)
    return unique([first(trace) for trace in raw_traces])
end


function extract_end_activities(eventlog::EventLog)
    raw_traces = get_raw_traces(eventlog)
    return unique([last(trace) for trace in raw_traces])
end


function alpha_miner(eventlog)

    raw_traces = get_raw_traces(eventlog)
    activities = get_activities(eventlog)

    direct_succession = get_direct_succession_relation(eventlog)
    causality = get_causality_relation(eventlog)
    parallel = get_parallel_relation(eventlog)
    choice = get_choice_relation(eventlog)

    start_activities = extract_start_activities(eventlog)
    end_activities = extract_end_activities(eventlog)


    powset = collect(powerset(activities, 1))
    combs = with_replacement_combinations(powset, 2)

    x_l = []
    for (i, c) in enumerate(combs)
        if (
            valid_within(c[1], choice)
            & valid_within(c[2], choice)
            & valid_between(c, causality)
        )
            push!(x_l, c)
        end
    end

    y_l = delete_non_maximal_pairs(x_l)

    p_l = y_l
    pushfirst!(p_l, [[], start_activities])
    push!(p_l, [end_activities, []])

    transition_map = @chain activities begin
        enumerate
        collect
        Dict
        Dict(value => key for (key, value) in _)
    end

    place_map = @chain p_l begin
        enumerate
        collect
        Dict
        # Dict(value => key for (key, value) in _)
    end

    # place_map_reverse = @chain p_l begin
    #     enumerate
    #     collect
    #     Dict
    #     Dict(value => key for (key, value) in _)
    # end

    pn = SimplePetriNet()

    for i in 1:length(activities)
        add_transition!(pn, Place[], Place[])
    end

    for i in 1:length(p_l)
        add_place!(pn, 0)
    end

    for p in pn.places
        tmp = place_map[p.id]
        for src_t in tmp[1]
            t = transition_map[src_t]
            push!(pn.transitions[t].to, p)
        end
        for dst_t in tmp[2]
            t = transition_map[dst_t]
            push!(pn.transitions[t].from, p)
        end
    end

    # transitions = activities
    # places = y_l

    return pn
end


function valid_within(set, choice_relation)
    for (a, b) in combinations(set, 2)
        if (a, b) in choice_relation
            return false
        end
    end
    return true
end


function valid_between(pair, causality)
    for tup in Iterators.product(pair[1], pair[2])
        if !(tup in causality)
            return false
        end
    end
    return true
end


function delete_non_maximal_pairs(x)
    maximal = []
    for pair1 in x
        flag = true
        for pair2 in x
            if !(pair1 == pair2)
                if issubset(pair1[1], pair2[1]) & issubset(pair1[2], pair2[2])
                    flag = false
                    break
                end
            end
        end
        if flag
            push!(maximal, pair1)
        end
    end
    return maximal
end







# function mine_all_place_pairs(eventlog::EventLog)
#     activity_traces = extract_activity_traces(eventlog)
#     activity_set = extract_activity_set(eventlog)
#     direct_succession = DirectSuccessionRelation(eventlog)
#     causality = CausalityRelation(eventlog)
#     parallel = ParallelRelation(eventlog)
#     choice = ChoiceRelation(eventlog)
#     # THIS WILL CERTAINLY NOT WORK (COMBINATORIC EXPLOSION)!
#     #   THERE HAS TO BE AN ITERATIVE WAY WITH A STOP CRITERIUM,
#     #   BUT A BETTER ONE THAN THE PREVIOUS APPROACH IMPLEMENTED
#     #   IN `iteratively_build_x`
#     # activity_powerset = powerset(activity_set, 1)
#     # place_set = Set()  # X_l
#     # for a in activity_powerset
#     #     for b in activity_powerset
#     #         print(a, b)
#     #     end
#     # end
# end


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
# begin
#     eventlog = read_xes(joinpath("data", "running-example.xes"))
#     extracted_activity_traces = extract_activity_traces(eventlog)
#     start_activities = extract_start_activities(eventlog)
#     end_activities = extract_end_activities(eventlog)
#     activity_set = extract_activity_set(eventlog)

#     all_pairs_iterator = Iterators.product(activity_set, activity_set)

#     direct_succession_relation = extract_direct_succession_relation(extracted_activity_traces)
#     causality_relation = extract_causality_relation(direct_succession_relation)
#     parallel_relation = extract_parallel_relation(direct_succession_relation)
#     choice_relation = extract_choice_relation(direct_succession_relation, activity_set)
#     X = iteratively_build_x(causality_relation, choice_relation)
# end
