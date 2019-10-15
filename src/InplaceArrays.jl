module InplaceArrays

using Reexport

export InplaceArray
export getindex!

include("CachedArrays.jl")
@reexport using InplaceArrays.CachedArrays

include("Functors.jl")
@reexport using InplaceArrays.Functors

include("Arrays.jl")
@reexport using InplaceArrays.Arrays

include("CellValues.jl")
@reexport using InplaceArrays.CellValues

include("Fields.jl")
@reexport using InplaceArrays.Fields

include("CellFields.jl")
@reexport using InplaceArrays.CellFields

end # module
