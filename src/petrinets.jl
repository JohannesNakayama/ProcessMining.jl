using AutoHashEquals

mutable struct PetriNet
    places::Array{Place}
    transitions::Array{Transition}
    arcs::Array{Union{Tuple{Place, Transition}, Tuple{Transition, Place}}}
end

mutable struct Place
    id::Int
    marking::Int
end

@auto_hash_equals mutable struct Transition
    id::Int
end

function fire!(transition::Transition, model::PetriNet)
    if is_enabled(tranition, model)
        update_markings!(transition, model)
    else
        print("Transition is not enabled\nDid not fire")
    end
    return model
end

function is_enabled(transition::Transition, model::PetriNet)
    predecessors = get_predecessors(transition, model)
    return sum([place.marking > 0 for place in predecessors]) == length(predecessors)
end

function get_predecessors(transition::Transition, model::PetriNet)
    return [arc[1] for arc in model.arcs if arc[2] == transition]
end

function get_successors(transition::Transition, model::PetriNet)
    return [arc[2] for arc in model.arcs if arc[1] == transition]
end

function update_markings!(transition::Transition, model::PetriNet)
    for predecessor in get_predecessors(transition, model)
        predecessor.marking -= 1
    end
    for successor in get_successors(transition, model)
        successor.marking += 1
    end
    return model
end

function add_place!(model::PetriNet, marking::Int)
    new_place_id = length(model.places) + 1
    push!(model.places, Place(new_place_id, marking))
    return model
end

function add_transition!(model::PetriNet)
    new_transition_id = length(model.transitions) + 1
    push!(model.transitions, Transition(new_transition_id))
    return model
end

function add_arc!(model::PetriNet, from::Place, to::Transition)
    push!(model.arcs, (from, to))
    return model
end

function add_arc!(model::PetriNet, from::Transition, to::Place)
    push!(model.arcs, (from, to))
    return model
end

# light weight version test
places = [Place(1, 2), Place(2, 0)]
transitions = [Transition(1)]
arcs = [(places[1], transitions[1]), (transitions[1], places[2])]
model = PetriNet(places, transitions, arcs)
fire(model.transitions[1], model)
model
add_place!(model, 3)
add_transition!(model)
add_arc!(model, model.places[1], model.transitions[2])
add_arc!(model, model.transitions[2], model.places[2])

# ----- MORE IDEAS ----- #
# reachability graph
# boundedness
# safeness
# deadlocks
# liveness
