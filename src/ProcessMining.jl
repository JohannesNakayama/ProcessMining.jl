module ProcessMining

    import EzXML
    import DataFrames
    using Graphs
    using MetaGraphs
    using Chain
    using Combinatorics
    using ProgressMeter

    const DEFAULT_NAMESPACE = "http://www.xes-standard.org/"

    export Event
    export Trace
    export EventLog
    export read_xes

    export info
    export length

    export PetriNet
    export Transition
    export Place
    export add_place!
    export add_transition!
    export fire!
    export fire
    export fire_sequence
    export is_enabled

    export to_dot
    export write_dot

    export DirectlyFollowsGraph
    export dfg_miner
    export prune_dfg!

    export alpha_miner
    export get_raw_traces
    export get_activities

    include("io/eventlog.jl")
    include("io/io.jl")
    include("process_models/petrinet.jl")
    include("process_models/dfg.jl")
    include("utilities.jl")
    include("miners/dfg_miner.jl")
    include("miners/alpha_miner.jl")
    include("visualization.jl")

end
