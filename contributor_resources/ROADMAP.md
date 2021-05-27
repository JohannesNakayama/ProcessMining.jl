# Next Steps

### Input/Output

IO works on a sufficient number of .xes test files (read from + write to xes)  
data structures for event logs are finished

### Workflow Models:

submodule for petri nets finished
three test cases for petri nets

### Algorithms

naive approach: 

    + pruned directly follows graph
    + pruning function (on footprint / graph)

alphaminer

### CI/CD:

set up travis + appveyor properly

### Documentation:

write documentation for existing code
establish guidelines for continuous documentation
integrate/render documentation




# Further down the Road

inductive miner
heuristic miner
visualization of results (probably using dot format from graphviz)
conformance checking 
simulation 
play in / play out / replay
.csv and database API 
CI/CD covers a sufficient range of systems
IO supports legacy file types (particularly .mxml)
set up a project website

### Way down the Road

if enough people participate: set up infrastructure for community (slack or similar)




# General Guidelines for PRs

code should be clean and documented
naming conventions are [standard Julia naming conventions](https://docs.julialang.org/en/v1/manual/style-guide/)
some conventions for functions: 

    + should be short and concise
    + should do what the name implies (and nothing more)
    
correctness first, then optimization
minimize dependencies




# Testing

will probably be implemented with [SafeTestsets.jl](https://github.com/YingboMa/SafeTestsets.jl)