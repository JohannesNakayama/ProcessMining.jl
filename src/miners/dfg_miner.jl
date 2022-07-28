# TODO: refactor
function dfg_miner(eventlog::EventLog)
    event_tuples = Tuple[]
    activities = String[]
    for trace in eventlog.traces
        trace_activities = [e.name for e in trace.events]
        trace_pairs = [
            (trace_activities[i], trace_activities[i + 1])
            for i in 1:(length(trace_activities) - 1)
        ]
        append!(event_tuples, deepcopy(trace_pairs))
        unique!(append!(activities, deepcopy(trace_activities)))
    end

    # (value => key) for lookup in edge construction
    activity_map = @chain activities begin
        enumerate
        collect
        Dict
        Dict(value => key for (key, value) in _)
    end

    event_tuples_numeric = Tuple[]
    for tup in event_tuples
        push!(
            event_tuples_numeric,
            (activity_map[tup[1]], activity_map[tup[2]])
        )
    end

    graph = MetaDiGraph(length(activity_map))
    for edge in event_tuples_numeric
        if has_edge(graph, edge[1], edge[2])
            curr_weight = get_prop(graph, edge[1], edge[2], :weight)
            set_prop!(graph, edge[1], edge[2], :weight, curr_weight + 1)
        else
            add_edge!(graph, edge[1], edge[2])
            set_prop!(graph, edge[1], edge[2], :weight, 1)
        end
    end

    # re-reverse activity map
    activity_map = Dict(value => key for (key, value) in activity_map)

    return DirectlyFollowsGraph(graph, activity_map)
end

function prune_dfg!(dfg::DirectlyFollowsGraph, min_weight::Int)
    for e in edges(dfg.graph)
        if get_prop(dfg.graph, src(e), dst(e), :weight) < min_weight
            rem_edge!(dfg.graph, src(e), dst(e))
        end
    end
    return dfg
end


# for plotting
# requires: Plots, GraphRecipes
# graphplot(g, curves = false)
