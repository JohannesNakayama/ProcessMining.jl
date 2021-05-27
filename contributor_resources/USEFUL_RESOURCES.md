# Julia

[This tutorial](https://www.youtube.com/watch?v=QVmU29rCjaA) was really helpful for me to learn about how to develop Julia packages. As of recently, the [documentation for Pkg.jl](https://docs.julialang.org/en/v1/stdlib/Pkg/) has become much more helpful as well. 

[EzXML.jl](https://juliaio.github.io/EzXML.jl/stable/) was used to implement the I/O operations on event logs. So far, the logs are handled completely in RAM, but the package seems to provide some streaming options for big files that we should look into.

[LightGraphs.jl](https://juliagraphs.org/LightGraphs.jl/stable/) is a library for graphs and networks in Julia. It includes implementations of most major graph algorithms and generators and it comes with some nice interoperability with additional network visualization tools. 

Testing will probably be implemented with [SafeTestsets.jl](https://github.com/YingboMa/SafeTestsets.jl).

So far, the I/O module only supports XES files, but in the future, CSV and other tabular formats should be supported as well. At that point, we will likely need [DataFrames.jl](https://dataframes.juliadata.org/stable/).

[Chris Rackauckas](https://github.com/ChrisRackauckas) is a great person to follow on Github for anyone interested in Julia. :grin:




# Process Mining

If you're new to process mining, [this course](https://www.coursera.org/learn/process-mining) is a fantastic place to start.

The [XES Standard](https://xes-standard.org/) extends XML to provide a grammar for event logs. The [standard definition](https://xes-standard.org/_media/xes/xesstandarddefinition-2.0.pdf) is a dry, but useful read for the event log data structures in ProcessMining.jl.

Some data to play around with can be found [here](http://www.processmining.org/book/start).

Other open source process mining tools include [ProM](https://www.promtools.org/doku.php) and [PM4PY](https://pm4py.fit.fraunhofer.de/). 
[RapidProM](http://rapidprom.org/) is a process mining extension for RapidMiner(https://rapidminer.com/). 
[Celonis](https://www.celonis.com/) is a commercial tool with some free options for small use cases as well as for students and academic contexts (afaik). 




# Visualization

[GraphViz](https://graphviz.org/) is a graph visualization software with APIs to many languages. It works on the [DOT language](https://graphviz.org/doc/info/lang.html) which is basically a graph markup language. There is a [Julia interface](https://github.com/Keno/GraphViz.jl) to GraphViz, but the package is not registered and the project seems to be abandoned. For the visualization of Workflow nets, we might look into building our own DOT engine, however, we will probably not need to build a module that implements all of the DOT language as we will likely need only parts of it. 

A nice tool for exploring the DOT language is the [Edotor](https://edotor.net/).

A little further down the line, we might look into [Dash.jl](https://github.com/plotly/Dash.jl) to provide users with a dashboard. 




# APIs

As an example for a very good API, I recommend [scikit-learn](https://scikit-learn.org/stable/getting_started.html), a Python library which provides implementations of most common machine learning models. 
This is a little bit off topic, but in terms of the ProcessMining.jl API, I want to achieve a workflow that "feels" a little bit similar. Imo, the scikit-learn API abstracts from the machine learning workflow very well. Most models are built like this:

```
from sklearn.some_module import SomeMachineLearningModel

model = SomeMachineLearningModel(specifications)  # first, the model is instantiated, potentially with custom specifications
model.fit(X_train, y_train)  # where X and y are conventions for naming features and labels respectively
model.predict(X_test)
model.score(X_test, y_test)
```

With the `fit` method, the model "is fitted to the data". 
With the `predict` method, the labels of unknown data with the same structure as the training data can be predicted.  
The `score` method is used to determine how good the model is.

Obviously, this is severely oversimplified, but understanding these very simple concepts gets you surprisingly far when learning scikit-learn. My goal for ProcessMining.jl is that it will be similarly intuitive to use. 




# Code Style

[Clean Code](https://www.oreilly.com/library/view/clean-code-a/9780136083238/) is a great read with regard to writing readable and maintainable code (this is not an affiliate link). The book is not cheap, but imo it's worth the money. However, "clean code" has become a notion in and off itself and there are boatloads of free resources on the Internet too. [This gist](https://gist.github.com/wojteklu/73c6914cc446146b8b533c0988cf8d29) is a good reference guide for the book, but I think it will be most useful to people who have already read it.





THIS IS A WORK IN PROGRESS. 