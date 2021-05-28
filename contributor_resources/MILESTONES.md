# :checkered_flag: Milestones for 2021 :checkered_flag:

This document outlines the next milestones for this project that I hope will be reachable in 2021. I attempted to be as concise as possible and to formulate goals that will allow us to check off milestones as we go. 




---

### Milestone 1: Proof of Concept

*Target Date*: to be determined

As a proof of concept, for milestone 1, ProcessMining.jl should be able to provide a very basic "naive" workflow that enables mining and pruning directly-follows graphs from event logs. For that, the types and structs for the algorithm inputs and outputs should be relatively solid already. I/O operations take specific precedence in this phase: This should work reliably. In the best case, this is already good enough so that it doesn't change too much in the future. 

**Requirements**:

:yellow_circle: Event Log API is solid: All types are defined, read/write from/to XES works, code is clean and refactored. A sufficient number of test cases on example data should exist to ensure reliability.

:yellow_circle: The Petri Nets module works: All types are defined and the API is usable.

:yellow_circle: CI/CD is set up with Travis CI and Appveyor. 

:red_circle: Implementation of pruned directly-follows graphs: DFGs can be inferred from event logs and interactively pruned. 





---

### Milestone 2: Educational Use

*Target Date*: to be determined

It will take some time until this package will be usable for professional use cases. However, a great start might be if students could use this as a tool to get acquainted with the basic techniques of process mining. This requires some educational resources (tutorials, notebooks) as well as an intuitive API and good documentation.

**Requirements**:

:red_circle: Testing covers at least 80% of the code (this will be measured with the [code coverage measure](https://docs.codecov.io/docs)). Testing is implemented with [SafeTestsets.jl](https://github.com/YingboMa/SafeTestsets.jl).

:red_circle: All functions of the user-facing API are documented with doc strings in the code. Furthermore, an online documentation page is set up and available on the project github page.

:red_circle: Alpha Miner works: The Alpha algorithm is implemented and works reliably. A workflow that gets the user from a XES event log to a workflow net should be established.

:red_circle: Educational materials with example are set up (maybe part of the documentation, or--alternatively--as scripts within the repository). [Pluto.jl](https://github.com/fonsp/Pluto.jl) looks promising for this. 




---

### Milestone 3: Community Building

*Target Date*: to be determined

Once people are using the tools, we hope that we might find more collaborators to join the project. This will require some infrastructure to keep in touch and organize a community. 

**Requirements**:

:red_circle: A `HOW_TO_CONTRIBUTE.md` guide is written and available in the repository (code style, communication, house rules etc.).  

:red_circle: Communication is organized on Slack or Discord (provided the number of collaborators warrants it, that is).  

:red_circle: A project website gives an overview and a detailed introduction to the project. 

:red_circle: Testing covers close to 100% of the code.  


---

### Milestone 4: Preparation for Registration

*Target Date*: to be determined

At this point, we can start implementing more complex techniques as they fit into the established workflows. More techniques can be added iteratively. As of now, it is too early to plan any further ahead than this, but once we get to this milestone, we should clearly line out further milestones, similar to the preceding ones.

**Requirements**:

:red_circle: Inductive Miner algorithm works.  

:red_circle: Next four milestones are clearly defined and listed in this document, similar to the existing ones.




























