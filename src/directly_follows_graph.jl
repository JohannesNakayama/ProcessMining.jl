# input event log
using Pkg
Pkg.activate(".")
using ProcessMining
using Graphs
using SimpleWeightedGraphs
using Plots
using GraphRecipes
using Chain

eventlog = read_xes("data/running-example.xes")

function dfg_miner(eventlog::EventLog)

    directly_follows = Tuple[]
    for trace in eventlog.traces
        activities = [e.name for e in trace.events]
        trace_pairs = [
            (activities[i], activities[i + 1])
            for i in 1:(length(activities) - 1)
        ]
        append!(directly_follows, trace_pairs)
    end

    activity_set = @chain directly_follows begin
        Iterators.flatten
        collect
        unique
        enumerate
        collect
        Dict
        Dict(value => key for (key, value) in _)
    end

    directly_follows_numeric = Tuple[]
    for tup in directly_follows
        push!(
            directly_follows_numeric,
            (activity_set[tup[1]], activity_set[tup[2]])
        )
    end

    g = SimpleWeightedDiGraph(length(activity_set))
    for edge in directly_follows_numeric
        if has_edge(g, edge[1], edge[2])
            g.weights[edge[1], edge[2]] += 1
        else
            add_edge!(g, edge[1], edge[2], 1)
        end
    end

    return g
end



# graphplot(g, curves = false)
