mutable struct DirectlyFollowsGraph
    graph::SimpleWeightedDiGraph
    activity_map::AbstractDict
end

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

    graph = SimpleWeightedDiGraph(length(activity_map))
    for edge in event_tuples_numeric
        if has_edge(graph, edge[1], edge[2])
            graph.weights[edge[1], edge[2]] += 1
        else
            add_edge!(graph, edge[1], edge[2], 1)
        end
    end

    return DirectlyFollowsGraph(graph, activity_map)
end

# for plotting
# requires: Plots, GraphRecipes
# graphplot(g, curves = false)
