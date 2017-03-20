
"""
    convertPyColumn(pycol::PyObject)

Converts a column of a pandas array to a Julia `NullableArray`.
"""
function convertPyColumn(pycol::PyObject)::NullableArray
    nptype = pycol[:dtype][:kind]
    # list of numpy kinds can be found at 
    # http://docs.scipy.org/doc/numpy/reference/arrays.dtypes.html
    if nptype == "O"
        o = NullableArray([x == nothing ? Nullable() : x for x in pycol])
        return o
    elseif nptype == "M"
        # doubt there are subtle efficiency differences between these, but it's possible
        o = NullableArray{DateTime}(
            [isa(t, PyObject) ? Nullable{DateTime}() : Nullable{DateTime}(t) for t in pycol])
        # (o = NullableArray(Nullable{DateTime}[isa(t, PyObject) ? Nullable() : t for t in
        #                                        pycol]))
        return o
    else
        return NullableArray(pycol[:values])
    end
end
export convertPyColumn


function _inferColumnType(col::NullableArray; max_elements::Integer=100)::DataType
    for i in 1:max_elements
        isnull(col) ? continue : nothing
        thistype = typeof(get(col[i]))
        thistype == PyObject ? continue : nothing
        return thistype
    end
    return Any
end


function _fillNewCol!{T, U}(newcol::NullableArray{T}, oldcol::NullableArray{U})
    for i in 1:length(newcol)
        if isnull(oldcol[i])
            newcol[i] = Nullable()
        else
            newcol[i] = get(oldcol[i])
        end
    end
end


"""
    fixColumnTypes!(df)

Check to see if the dataframe `df` has any columns of type `Any` and attempt to convert
them to the proper types.  This can be called from `convertPyDF` with the option
`fixtypes`.
"""
function fixColumnTypes!(df::DataTable)
    for col in names(df)
        if eltype(eltype(df[col])) ≠ Any continue end
        dtype = _inferColumnType(df[col])
        # I can't find any way around getting into these stupid loops
        newcol = NullableArray{dtype}(length(df[col]))
        _fillNewCol!(newcol, df[col])
        df[col] = newcol
    end
end
export fixColumnTypes!


"""
    convertPyDF(pydf[, fixtypes=true])

Converts a pandas dataframe to a Julia one.  

Note that it is difficult to infer the correct types of columns which contain references
to Python objects.  If `fixtypes`, this will attempt to convert any column with eltype
`Any` to the proper type.
"""
function convertPyDF(pydf::PyObject; fixtypes::Bool=true)::DataTable
    df = DataTable()
    for col in pydf[:columns]
        df[Symbol(col)] = convertPyColumn(get(pydf, PyObject, col))
    end
    if fixtypes fixColumnTypes!(df) end
    return df
end
export convertPyDF


"""
    fixPyNones(dtype, a)

Attempts to convert a `NullableArray` to have eltype `dtype` while replacing all Python
`None`s with `Nullable`.
"""
function fixPyNones{T}(::Type{T}, a::NullableArray)
    # exit silently if the array can't possibly hold Nones
    if !((eltype(a) == Any) | (eltype(a) == PyObject)) return end
    pyNone = pybuiltin("None")
    newa = NullableArray(x == pyNone ? Nullable() : convert(T, x) for x in a)
end
export fixPyNones


"""
    fixPyNones!(dtype::DataType, df::DataTable, col::Symbol)

Attempts to convert a column of the dataframe to have eltype `dtype` while replacing all
Python `None`s with `Nullable()`.
"""
function fixPyNones!{T}(::Type{T}, df::DataTable, col::Symbol)
    df[col] = fixPyNones(T, df[col])
    return df
end
export fixPyNones!


"""
    fixPyNones!(df::DataTable)

Attempts to automatically convert all columns of a dataframe to have eltype `Any` while
replacing all Python `None`s with `Nullable()`.
"""
function fixPyNones!(df::DataTable)
    for col in names(df)
        if eltype(df[col]) == PyObject
            fixPyNones!(Any, df, col)
        end
    end
end
export fixPyNones!


"""
    unpickle([dtype,] filename[, fixtypes=true])

Deserializes a python pickle file and returns the object it contains.
Additionally, if `DataTable` is given as the first argument, will
attempt to convert the object to a Julia dataframe with the flag
`fixtypes` (see `convertPyDF`).
"""
function unpickle(filename::String)::PyObject
    f = py"open($filename, 'rb')"
    pyobj = PyPickle[:load](f)
end

function unpickle(::Type{DataTable}, filename::AbstractString;
                  fixtypes::Bool=true)::DataTable
    f = py"open($filename, 'rb')"
    # TODO it may be more efficient to create this from a dictionary than to convert
    pydf = pycall(PyPickle[:load], PyObject, f)
    df = convertPyDF(pydf, fixtypes=fixtypes)
end
export unpickle


"""
    pickle(filename, object)

Converts the provided object to a PyObject and serializes it in
the python pickle format.  If the object provided is a `DataTable`,
this will first convert it to a pandas dataframe.
"""
function pickle(filename::String, object::Any)
    pyobject = PyObject(object)
    f = py"open($filename, 'wb')"
    PyPickle[:dump](pyobject, f)
end

function pickle(filename::String, df::DataTable)
    pydf = pandas(df)
    f = py"open($filename, 'wb')"
    PyPickle[:dump](pydf, f)
end
export pickle



"""
    pandas(df)

Convert a dataframe to a pandas pyobject.
"""
function pandas(df::DataTable)::PyObject
    pydf = pycall(PyPandas[:DataFrame], PyObject)
    for col in names(df)
        pycol = [isnull(x) ? nothing : get(x) for x in df[col]]
        set!(pydf, string(col), pycol)
        # convert datetime to proper numpy type
        if eltype(eltype(df[col])) == DateTime
            set!(pydf, string(col), 
                 get(pydf, string(col))[:astype]("<M8[ns]"))
        end
    end
    return pydf
end
export pandas


