"""
    AbstractPetriNet

An abstract type for all concrete types of Petri nets (e.g. Workflow nets).
"""
abstract type AbstractPetriNet end


"""
    Place

A `Place` in any concrete type below `AbstractPetriNet`.
"""
Base.@kwdef mutable struct Place
    id::Int
    name::String
    marking::Int
end


"""
    Transition

A `Transition` in any concrete type below `AbstractPetriNet`.
"""
Base.@kwdef mutable struct Transition
    id::Int
    name::String
    from::Array{Place}
    to::Array{Place}
end


"""
    PetriNet

A concrete implementation of standard Petri nets.
"""
Base.@kwdef mutable struct PetriNet <: AbstractPetriNet
    places::Array{Place}
    transitions::Array{Transition}
    function PetriNet(places = Place[], transitions = Transition[])
        new(places, transitions)
    end
end


function Base.show(io::IO, ::MIME"text/plain", place::Place)
    print("Place \"$(place.name)\", with ID $(place.id)")
end


function Base.show(io::IO, ::MIME"text/plain", transition::Transition)
    print("Transition \"$(transition.name)\", with ID $(transition.id)")
end


function Base.show(io::IO, ::MIME"text/plain", petrinet::PetriNet)
    print(
        "Petri net with "
        * "$(length(petrinet.places)) places and "
        * "$(length(petrinet.transitions)) transitions"
    )
end


"""
    add_place!(model::AbstractPetriNet; name::String="default", marking::Int=0)

Add a `Place` to any concrete type under `AbstractPetriNet`.

A `name` and an initial `marking` can be supplied.
Default values are `name="default"` and `marking=0`.
"""
function add_place!(
    model::AbstractPetriNet;
    name::String="default",
    marking::Int=0
)
    new_place_id = length(model.places) + 1
    push!(model.places, Place(new_place_id, name, marking))
    return model
end


"""
    add_transition!(model::AbstractPetriNet, from::Array{Place}, to::Array{Place}; name::String="default")

Add a `Transition` to any concrete type under `AbstractPetriNet`.

Supply `Place` arrays to `from` and `to` to add a `Transition` with arrows from the places in `from` to the places in `to`.
A name can be supplied optionally.
An id is auto-generated based on the supplied Petri net.
"""
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


"""
    add_transition!(model::AbstractPetriNet, from::Array{Int}, to::Array{Int}; name::String="default")

Add a `Transition` to any concrete type under `AbstractPetriNet`.

This is a convenience dispatch of `add_transition!` that takes `Int` arrays as `from` and `to` arguments.
`Place`s have `Int` ids, so they can easily be referenced numerically when creating `Transition`s.
"""
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


"""
    fire!(model::AbstractPetriNet, transition_id::Int)

Fire a transition in any concrete implementation of `AbstractPetriNet`.

The `fire!` function modifies the `AbstractPetriNet`, in that it consumes tokens (markings) from the `Place`s before the `Transition` and produces tokens in the `Place`s after the `Transition`.
"""
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


"""
    fire(model::AbstractPetriNet, transition_id::Int)

Return a copy of the supplied Petri net where the `Transition` with `id = transition_id` has been fired.

Behaves the same as the `fire!` function, but returns a copy of the supplied Petri net and doesn't change the model in-place.
"""
function fire(model::AbstractPetriNet, transition_id::Int)
    updated_model = deepcopy(model)
    fire!(updated_model, transition_id)
    return updated_model
end


"""
    fire_sequence(model::AbstractPetriNet, sequence::Array{Int})
    
Fire a sequence of `Transition`s in a supplied model of type <: AbstractPetriNet.
The sequence of `Transition`s is supplied as an `Int` array.
"""
function fire_sequence(model::AbstractPetriNet, sequence::Array{Int})
    output_model = deepcopy(model)
    for t in sequence
        fire!(output_model, t)
    end
    return output_model
end


"""
    is_enabled(model::AbstractPetriNet, transition_id::Int)

Return if a given `Transition` in a model <: `AbstractPetriNet` is enabled.

A transition is enabled if it can be fired, meaning all `Place`s with arrows to the transition have at least one token.
"""
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
