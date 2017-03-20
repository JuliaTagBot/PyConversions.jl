
<a id='PyConversions.jl-1'></a>

# PyConversions.jl


This package provides methods for converting from Python objects to Julia objects, as well as a minimal Julia interface to `pickle`. [PyCall.jl](https://github.com/JuliaPy/PyCall.jl) already provides an enormous amount of functionality for converting from Python objects to Julia objects, but it is somewhat lacking when it comes to specific python modules, notably `pandas`.  Much of PyConversions.jl is for converting to or from `pandas` dataframes.


<a id='API-Docs-1'></a>

## API Docs

<a id='PyConversions.convertPyColumn-Tuple{PyCall.PyObject}' href='#PyConversions.convertPyColumn-Tuple{PyCall.PyObject}'>#</a>
**`PyConversions.convertPyColumn`** &mdash; *Method*.



```
convertPyColumn(pycol::PyObject)
```

Converts a column of a pandas array to a Julia `NullableArray`.

<a id='PyConversions.convertPyDF-Tuple{PyCall.PyObject}' href='#PyConversions.convertPyDF-Tuple{PyCall.PyObject}'>#</a>
**`PyConversions.convertPyDF`** &mdash; *Method*.



```
convertPyDF(pydf[, fixtypes=true])
```

Converts a pandas dataframe to a Julia one.  

Note that it is difficult to infer the correct types of columns which contain references to Python objects.  If `fixtypes`, this will attempt to convert any column with eltype `Any` to the proper type.

<a id='PyConversions.fixColumnTypes!-Tuple{DataTables.DataTable}' href='#PyConversions.fixColumnTypes!-Tuple{DataTables.DataTable}'>#</a>
**`PyConversions.fixColumnTypes!`** &mdash; *Method*.



```
fixColumnTypes!(df)
```

Check to see if the dataframe `df` has any columns of type `Any` and attempt to convert them to the proper types.  This can be called from `convertPyDF` with the option `fixtypes`.

<a id='PyConversions.fixPyNones!-Tuple{DataTables.DataTable}' href='#PyConversions.fixPyNones!-Tuple{DataTables.DataTable}'>#</a>
**`PyConversions.fixPyNones!`** &mdash; *Method*.



```
fixPyNones!(df::DataTable)
```

Attempts to automatically convert all columns of a dataframe to have eltype `Any` while replacing all Python `None`s with `Nullable()`.

<a id='PyConversions.fixPyNones!-Tuple{Type{T},DataTables.DataTable,Symbol}' href='#PyConversions.fixPyNones!-Tuple{Type{T},DataTables.DataTable,Symbol}'>#</a>
**`PyConversions.fixPyNones!`** &mdash; *Method*.



```
fixPyNones!(dtype::DataType, df::DataTable, col::Symbol)
```

Attempts to convert a column of the dataframe to have eltype `dtype` while replacing all Python `None`s with `Nullable()`.

<a id='PyConversions.fixPyNones-Tuple{Type{T},NullableArrays.NullableArray}' href='#PyConversions.fixPyNones-Tuple{Type{T},NullableArrays.NullableArray}'>#</a>
**`PyConversions.fixPyNones`** &mdash; *Method*.



```
fixPyNones(dtype, a)
```

Attempts to convert a `NullableArray` to have eltype `dtype` while replacing all Python `None`s with `Nullable`.

<a id='PyConversions.pandas-Tuple{DataTables.DataTable}' href='#PyConversions.pandas-Tuple{DataTables.DataTable}'>#</a>
**`PyConversions.pandas`** &mdash; *Method*.



```
pandas(df)
```

Convert a dataframe to a pandas pyobject.

<a id='PyConversions.pickle-Tuple{String,Any}' href='#PyConversions.pickle-Tuple{String,Any}'>#</a>
**`PyConversions.pickle`** &mdash; *Method*.



```
pickle(filename, object)
```

Converts the provided object to a PyObject and serializes it in the python pickle format.  If the object provided is a `DataTable`, this will first convert it to a pandas dataframe.

<a id='PyConversions.unpickle-Tuple{String}' href='#PyConversions.unpickle-Tuple{String}'>#</a>
**`PyConversions.unpickle`** &mdash; *Method*.



```
unpickle([dtype,] filename[, fixtypes=true])
```

Deserializes a python pickle file and returns the object it contains. Additionally, if `DataTable` is given as the first argument, will attempt to convert the object to a Julia dataframe with the flag `fixtypes` (see `convertPyDF`).

