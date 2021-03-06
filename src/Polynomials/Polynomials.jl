"""
This module provides a collection of multivariate polynomial bases.

The exported names are:

$(EXPORTS)
"""
module Polynomials

using DocStringExtensions
using LinearAlgebra: mul!
using InplaceArrays.Helpers
using InplaceArrays.Inference
using InplaceArrays.Arrays
using InplaceArrays.TensorValues
using InplaceArrays.Fields

import InplaceArrays.Fields: evaluate_field!
import InplaceArrays.Fields: field_cache
import InplaceArrays.Fields: evaluate_gradient!
import InplaceArrays.Fields: gradient_cache
import InplaceArrays.Fields: evaluate_hessian!
import InplaceArrays.Fields: hessian_cache

export MonomialBasis
export QGradMonomialBasis
export QCurlGradMonomialBasis
export change_basis

include("MonomialBases.jl")

include("QGradMonomialBases.jl")

include("QCurlGradMonomialBases.jl")

include("ChangeBasis.jl")

end # module
