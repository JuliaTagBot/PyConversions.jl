__precompile__(true)

module PyConversions

using Reexport

using DataTables
@reexport using PyCall


const PyPickle = PyNULL()
const PyPandas = PyNULL()

function __init__()
    copy!(PyPickle, pyimport("pickle"))
    copy!(PyPandas, pyimport("pandas"))
end


include("dfutils.jl")









end
