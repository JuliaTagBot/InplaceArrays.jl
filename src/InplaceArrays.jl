"""
Gridap, grid-based approximation of PDEs in the Julia programming language

This module provides rich set of tools for the numerical solution of PDE, mainly based
on finite element methods.

The module is structured in the following sub-modules:

- [`InplaceArrays.Helpers`](@ref)
- [`InplaceArrays.Inference`](@ref)
- [`InplaceArrays.TensorValues`](@ref)
- [`InplaceArrays.Arrays`](@ref)
- [`InplaceArrays.Fields`](@ref)
- [`InplaceArrays.Polynomials`](@ref)
- [`InplaceArrays.ReferenceFEs`](@ref)

The exported names are:
$(EXPORTS)
"""
module InplaceArrays

using DocStringExtensions

include("Helpers/Helpers.jl")

include("Inference/Inference.jl")

include("TensorValues/TensorValues.jl")

include("Arrays/Arrays.jl")

include("Fields/Fields.jl")

include("Polynomials/Polynomials.jl")

include("ReferenceFEs/ReferenceFEs.jl")

end # module
