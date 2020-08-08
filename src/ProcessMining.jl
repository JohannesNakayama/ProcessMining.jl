module ProcessMining

    import EzXML

    const DEFAULT_NAMESPACE = "http://www.xes-standard.org/"

    export Event
    export Trace
    export EventLog
    export read_xes
    export info
    export length

    include("types.jl")
    include("io.jl")
    include("utilities.jl")
    include("tools.jl")
    include("algorithms.jl")

end
