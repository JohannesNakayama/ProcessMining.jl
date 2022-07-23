module ProcessMining

    import EzXML
    import DataFrames
    using Graphs
    using SimpleWeightedGraphs
    using Chain
    # using Combinatorics  # for alphaminer
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
    export add_places!
    export add_transition!
    # export petrinet_to_dot
    # export write_dot
    export DirectlyFollowsGraph
    export dfg_miner

    include("types.jl")
    include("petrinets.jl")
    include("io.jl")
    include("utilities.jl")
    include("algorithms.jl")
    # include("visualization.jl")
    include("directly_follows_graph.jl")

end
