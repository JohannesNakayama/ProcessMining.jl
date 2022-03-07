module ProcessMining

    import EzXML
    import DataFrames
    # using AutoHashEquals

    const DEFAULT_NAMESPACE = "http://www.xes-standard.org/"


    export Event
    export Trace
    export EventLog
    export read_xes
    export info
    export length
    export SimplePetriNet
    export WorkflowNet
    export Transition
    export Place
    export fire!
    export fire
    export fire_sequence
    export is_enabled
    export add_place!
    export add_transition!


    include("types.jl")
    include("petrinets.jl")
    include("io.jl")
    include("utilities.jl")
    include("algorithms.jl")

end
