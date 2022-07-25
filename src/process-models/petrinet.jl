abstract type AbstractPetriNet end


mutable struct Place
    id::Int
    name::String
    marking::Int
end


mutable struct Transition
    id::Int
    name::String
    from::Array{Place}
    to::Array{Place}
end


Base.@kwdef mutable struct PetriNet <: AbstractPetriNet
    places::Array{Place}
    transitions::Array{Transition}
    function PetriNet(places = Place[], transitions = Transition[])
        new(places, transitions)
    end
end


function add_place!(
    model::AbstractPetriNet;
    name::String="default",
    marking::Int=0
)
    new_place_id = length(model.places) + 1
    push!(model.places, Place(new_place_id, name, marking))
    return model
end


function add_transition!(
    model::AbstractPetriNet,
    from::Array{Place},
    to::Array{Place};
    name::String="default"
)
    push!(
        model.transitions,
        Transition(length(model.transitions) + 1, name, from, to)
    )
    return model
end


function add_transition!(
    model::AbstractPetriNet,
    from::Array{Int},
    to::Array{Int};
    name::String="default"
)
    predecessors = [p for p in model.places if p.id in from]
    successors = [p for p in model.places if p.id in to]
    push!(
        model.transitions,
        Transition(
            length(model.transitions) + 1,
            name,
            predecessors,
            successors
        )
    )
    return model
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




# ----- MORE IDEAS ----- #
# reachability graph
# boundedness
# safeness
# deadlocks
# liveness
