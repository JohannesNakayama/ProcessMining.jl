using ProcessMining
using Test

@time ProcessMining.read_xes(joinpath("data", "Performance.xes"))
