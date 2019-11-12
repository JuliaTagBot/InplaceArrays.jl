"""
This module provides:
- An extension of the `AbstractArray` interface in order to properly deal with mutable caches.
- A mechanism to generate lazy arrays resulting from operations between arrays.
- A collection of concrete implementations of `AbstractArray`.

The exported names in this module are:

$(EXPORTS)
"""
module Arrays

using InplaceArrays.Helpers
using InplaceArrays.Inference

using DocStringExtensions
using Test
using FillArrays
using Base: @propagate_inbounds

export array_cache
export getindex!
export getitems!
export testitem
export uses_hash
export test_array
export testitems
export array_caches

export CachedArray
export CachedMatrix
export CachedVector
export setsize!

export CompressedArray
export LocalToGlobalArray
export Table

export kernel_cache
export kernel_caches
export apply_kernels!
export apply_kernel!
export apply_kernel
export test_kernel
export bcast
export elem
export contract
export kernel_return_type
export kernel_return_types
export Kernel

export apply
export apply_all

import Base: size
import Base: getindex, setindex!
import Base: similar
import Base: IndexStyle

include("Interface.jl")

include("CachedArrays.jl")

include("Kernels.jl")

include("Apply.jl")

include("CompressedArrays.jl")

include("Tables.jl")

include("LocalToGlobalArrays.jl")

end # module
