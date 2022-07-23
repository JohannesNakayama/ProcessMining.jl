# naive hacky implementation
# improve later
# just for quick look at results

function petrinet_to_dot(pn::AbstractPetriNet, graphname::String)
    place_list = [string(place.id) for place in pn.places]
    transition_list = ["t" * string(t.id) for t in pn.transitions]

    edge_list = []
    for transition in pn.transitions
        for edge_from in transition.from
            edge_tuple = (edge_from.id, "t" * string(transition.id))
            push!(edge_list, edge_to_dot(edge_tuple))
        end
        for edge_to in transition.to
            edge_tuple = ("t" * string(transition.id), edge_to.id)
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
