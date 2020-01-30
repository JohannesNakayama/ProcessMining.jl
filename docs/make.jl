using Documenter, ProcessMining

makedocs(;
    modules=[ProcessMining],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/JohannesNakayama/ProcessMining.jl/blob/{commit}{path}#L{line}",
    sitename="ProcessMining.jl",
    authors="Johannes Nakayama",
    assets=String[],
)

deploydocs(;
    repo="github.com/JohannesNakayama/ProcessMining.jl",
)
