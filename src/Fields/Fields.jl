"""
This module provides:

- An interface for physical fields, basis of physical fields and related objects.
- Helpers functions to work with fields and arrays of fields.
- Helpers functions to create lazy operation trees from fields and arrays of fields

The exported names are:

$(EXPORTS)
"""
module Fields

using InplaceArrays.Helpers
using InplaceArrays.Inference
using InplaceArrays.TensorValues
using InplaceArrays.Arrays
using InplaceArrays.Arrays: BCasted
using InplaceArrays.Arrays: NumberOrArray
using InplaceArrays.Arrays: AppliedArray
using InplaceArrays.Arrays: Contracted

using Test
using DocStringExtensions
using FillArrays

export Point
export field_gradient
export evaluate_field!
export evaluate_field
export field_cache
export field_return_type
export evaluate
export evaluate!
export gradient
export ∇
export Field
export test_field
export apply_kernel_to_field
export apply_to_field_array
export test_array_of_fields
export compose
export lincomb
export varinner
export attachmap
export integrate
export field_caches
export field_return_types
export evaluate_fields
export evaluate_fields!
export field_gradients
export field_array_cache
export evaluate_field_array
export field_array_gradient
export gradient_type
export curl
export grad2curl
export laplacian
export divergence
export Δ
export ε

import InplaceArrays.Arrays: kernel_cache
import InplaceArrays.Arrays: apply_kernel!
import InplaceArrays.Arrays: kernel_return_type
import InplaceArrays.TensorValues: outer
import InplaceArrays.TensorValues: inner
import InplaceArrays.TensorValues: symmetic_part
import Base: +, - , *
import LinearAlgebra: cross
import LinearAlgebra: tr
import Base: transpose
import Base: adjoint

include("FieldInterface.jl")

include("MockFields.jl")

include("ConstantFields.jl")

include("FieldApply.jl")

include("FieldArrays.jl")

include("Lincomb.jl")

include("Compose.jl")

include("Varinner.jl")

include("Attachmap.jl")

include("Integrate.jl")

include("FieldOperations.jl")

include("DiffOperators.jl")

end # module
