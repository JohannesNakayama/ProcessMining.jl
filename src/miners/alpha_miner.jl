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

# TODO: improve documentation

"""
    alpha_miner(eventlog::EventLog)

Perform the alpha miner algorithm on a given `EventLog`.

The return value is a `PetriNet`.
"""
function alpha_miner(eventlog::EventLog)

    # preparations
    raw_traces = get_raw_traces(eventlog)
    activities = get_activities(eventlog)

    direct_succession = get_direct_succession_relation(eventlog)
    causality = get_causality_relation(eventlog)
    choice = get_choice_relation(eventlog)

    start_activities = get_start_activities(eventlog)
    end_activities = get_end_activities(eventlog)

    # iterators
    reduced_powset = [
        elem
        for elem in collect(powerset(activities, 1))
        if valid_within(elem, choice)
    ]
    combs = with_replacement_combinations(reduced_powset, 2)

    # extract place pairs
    x_l = []
    @showprogress "Alpha Miner..." for (i, c) in enumerate(combs)
        if valid_between(c, causality)
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
    end

    pn = PetriNet()

    for i in 1:length(activities)
        add_transition!(pn, Place[], Place[], name = activities[i])
    end

    for i in 1:length(p_l)
        add_place!(pn, marking = 0)
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

    # add marking to source
    pn.places[1].marking = 1

    return pn
end


"""
    get_raw_traces(eventlog::EventLog)

Get `Trace`s of a given `EventLog` as string arrays.

It is not always useful to have traces as `Event[]` objects.
In some cases, it is useful to just have the raw string representation, where each event in a trace is represented by its name as a string.
"""
function get_raw_traces(eventlog::EventLog)
    return [
        [event.name for event in trace.events]
        for trace in eventlog.traces
    ]
end


"""
    get_activities(eventlog::EventLog)

Get all unique activities in an `EventLog`.
"""
function get_activities(eventlog::EventLog)
    return @chain eventlog begin
        get_raw_traces
        Iterators.flatten
        collect
        unique
    end
end


"""
    get_direct_succession_relation(eventlog::EventLog)

Get the direct succession relation from a given `EventLog`.

A tuple of events (a, b) is defined to be in the direct succession relation if a trace exists, where b directly follows a.
"""
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


"""
    get_causality_relation(eventlog::EventLog)

Get the causality relation from a given `EventLog`.
"""
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


"""
    get_parallel_relation(eventlog::EventLog)

Get the parallel relation from a given `EventLog`.
"""
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


"""
    get_choice_relation(eventlog::EventLog)

Get the choice relation from a given `EventLog`.
"""
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


"""
    get_start_activities(eventlog::EventLog)

Get the set of start activities from a given `EventLog`.
"""
function get_start_activities(eventlog::EventLog)
    raw_traces = get_raw_traces(eventlog)
    return unique([first(trace) for trace in raw_traces])
end


"""
    get_end_activities(eventlog::EventLog)

Get the set of end activities from a given `EventLog`.
"""
function get_end_activities(eventlog::EventLog)
    raw_traces = get_raw_traces(eventlog)
    return unique([last(trace) for trace in raw_traces])
end


"""
    valid_within(set, choice_relation)

Test whether each 2-combination of activities are in the choice relation.

This is a necessary criterion for the set `X_l` in the alpha algorithm.
"""
function valid_within(set, choice_relation)
    for (a, b) in combinations(set, 2)
        if (a, b) in choice_relation
            return false
        end
    end
    return true
end


"""
    valid_between(pair, choice_relation)

Test whether each pair (a, b) of elements in two sets A and B are in the choice relation.

This is a necessary criterion for the set `X_l` in the alpha algorithm.
"""
function valid_between(pair, causality)
    for tup in Iterators.product(pair[1], pair[2])
        if !(tup in causality)
            return false
        end
    end
    return true
end


"""
    delete_non_maximal_pairs(x)

Delete all non-maximal pairs from a generated set of place pairs `X_l`.

This step removes redundant place pairs as an intermediate step in the alpha algorithm.
"""
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

