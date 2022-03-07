abstract type AbstractPetriNet end


mutable struct Place
    id::Int
    marking::Int
end


mutable struct Transition
    id::Int
    from::Array{Place}
    to::Array{Place}
end
# TODO: do we need auto_hash_equals? -> @auto_hash_equals
#       decide later


Base.@kwdef mutable struct SimplePetriNet <: AbstractPetriNet
    places::Array{Place}
    transitions::Array{Transition}
end


Base.@kwdef mutable struct WorkflowNet <: AbstractPetriNet
    source::Int
    sink::Int
    places::Array{Place}
    transitions::Array{Transition}
end


function fire!(model::AbstractPetriNet, transition_id::Int)
    if is_enabled(model, transition_id)
        for f in model.transitions[transition_id].from
            f.marking -= 1
        end
        for t in model.transitions[transition_id].to
            t.marking += 1
        end
    else
        println("Transition is not enabled.")
    end
    return model
end


function fire(model::AbstractPetriNet, transition_id::Int)
    updated_model = deepcopy(model)
    fire!(updated_model, transition_id)
    return updated_model
end


function fire_sequence(model::AbstractPetriNet, sequence::Array{Int})
    output_model = deepcopy(model)
    for t in sequence
        fire!(output_model, t)
    end
    return output_model
end


function is_enabled(model::AbstractPetriNet, transition_id::Int)
    transition = model.transitions[transition_id]
    return reduce(&, [(place.marking >= 1) for place in transition.from])
end


function add_place!(model::AbstractPetriNet, marking::Int)
    new_place_id = length(model.places) + 1
    push!(model.places, Place(new_place_id, marking))
    return model
end


function add_transition!(model::AbstractPetriNet, from::Array{Place}, to::Array{Place})
    push!(model.transitions, Transition(length(model.transitions) + 1, from, to))
    return model
end


function add_transition!(model::AbstractPetriNet, from::Array{Int}, to::Array{Int})
    predecessors = [p for p in model.places if p.id in from]
    successors = [p for p in model.places if p.id in to]
    push!(
        model.transitions,
        Transition(length(model.transitions) + 1, predecessors, successors)
    )
end


function add_transition!(model::AbstractPetriNet, from::Int, to::Int)
    predecessor = model.places[from]
    successor = model.places[to]
    push!(
        model.transitions,
        Transition(length(model.transitions) + 1, [predecessor], [successor])
    )
    return model
end



# ----- MORE IDEAS ----- #
# reachability graph
# boundedness
# safeness
# deadlocks
# liveness
