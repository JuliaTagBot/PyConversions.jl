# PyConversions.jl
This package provides methods for converting from Python objects to Julia objects, as well as a minimal Julia interface to `pickle`.
[PyCall.jl](https://github.com/JuliaPy/PyCall.jl) already provides an enormous amount of functionality for converting from Python objects to Julia objects, but
it is somewhat lacking when it comes to specific python modules, notably `pandas`.  Much of PyConversions.jl is for converting to or from `pandas` dataframes.

## API Docs
```@autodocs
Modules = [PyConversions]
Private = false
```

