# naive hacky implementation
# improve later
# just for quick look at results



function petrinet_to_dot(pn::AbstractPetriNet, graphname::String="mywfn")
    place_list = [string(place.id) for place in pn.places]
    if pn.transitions[1].name != "default"
        transition_list = ["\"" * t.name * "\"" for t in pn.transitions]
    else
        transition_list = ["t" * string(t.id) for t in pn.transitions]
    end

    edge_list = []
    for transition in pn.transitions
        for edge_from in transition.from
            if transition.name != "default"
                edge_tuple = (edge_from.id, "\"" * transition.name * "\"")
            else
                edge_tuple = (edge_from.id, "t" * string(transition.id))
            end
            push!(edge_list, edge_to_dot(edge_tuple))
        end
        for edge_to in transition.to
            if transition.name != "default"
                edge_tuple = ("\"" * transition.name * "\"", edge_to.id)
            else
                edge_tuple = ("t" * string(transition.id), edge_to.id)
            end
            push!(edge_list, edge_to_dot(edge_tuple))
        end
    end

    graph = []
    push!(graph, "digraph")
    push!(graph, graphname)

    push!(graph, "{")
    push!(graph, "rankdir=\"LR\";")

    # places
    push!(graph, "node [shape=circle]")
    for n in place_list
        push!(graph, string(n) * "; ")
    end
    # transitions
    push!(graph, "node [shape=box]")
    for n in transition_list
        push!(graph, string(n) * "; ")
    end
    # edges
    for e in edge_list
        push!(graph, e * ";")
    end

    push!(graph, "}")

    g = join(graph, " ")

    return g

end

function dfg_to_dot(dfg::DirectlyFollowsGraph, graphname::String)

    graph = []
    push!(graph, "digraph")
    push!(graph, graphname)

    push!(graph, "{")
    push!(graph, "rankdir=\"LR\";")
    push!(graph, "node [shape=circle]")

    for v in vertices(dfg.graph)
        push!(graph, "\"" * dfg.activity_map[v] * "\"" * "; ")
    end

    for e in edges(dfg.graph)
        push!(
            graph,
            "\""
            * dfg.activity_map[src(e)]
            * "\""
            * " -> "
            * "\""
            * dfg.activity_map[dst(e)]
            * "\""
            * "; "
        )
    end

    push!(graph, "}")

    g = join(graph, " ")

    return g
end


function write_dot(dot_graph::String, filename::String)
    open(filename, "w") do io
        write(io, dot_graph)
    end
    return true
end


function edge_to_dot(tup::Tuple)
    return string(tup[1]) * " -> " * string(tup[2])
end




# then do: `cat test.dot | dot -Tsvg > output.svg`
# graphviz needs to be installed, obviously
