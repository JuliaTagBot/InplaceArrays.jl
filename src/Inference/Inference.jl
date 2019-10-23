"""
This module provides a set of helper function to safely infer return types of functions.

In Gridap, we rely as less as possible in type inference. But, when needed, we adopt
the following mechanism in order to compute returned types. We do not rely on
the `Base._return_type` function.

This module exports following functions:
$(EXPORTS)

"""
module Inference

using DocStringExtensions

export testvalue
export testvalues
export testargs
export testargs_broadcast
export return_type
export return_type_broadcast

"""
$(TYPEDSIGNATURES)

Returns the type returned by function `f` when called with arguments
of the types in `Ts`.

The underlying implementation uses the function [`testargs`](@ref) to generate
some test values in order to call the function and determine the returned type.
This mechanism does not use `Base._return_type`. One of the advantages is
that the given function `f` is called, and thus, meaningful error messages
will be displayed if there is any error in `f`. 
    
"""
function return_type(f::Function,Ts...)
  args = testargs(f,Ts...)
  try
    typeof(f(args...))
  catch e
    if isa(e,DomainError)
      s = "Function $(nameof(f)) cannot be evaluated at $args, its not in the domain.\n"
      s *= " Define function `testargs(::typeof{$(nameof(f))},Ts...)`\n"
      s *= " which sould return an argument tuple in the function domain."
      error(s)
    else
      throw(e)
    end
  end

end

"""
    return_type_broadcast(f::Function,Ts::DataType...) -> DataType

Like [`return_type`](@ref), but when function `f` is used in a broadcast operation.
"""
function return_type_broadcast(f::Function,Ts...)
  args = testargs_broadcast(f,Ts...)
  r = broadcast(f,args...)
  typeof(r)
end

"""
$(SIGNATURES)
"""
function testargs_broadcast(f::Function,Ts...)
  v = testvalues(Ts...)
  Ys = map(eltype,Ts)
  y = testargs(f,Ys...)
  args = (_new_arg(vi,yi) for (vi,yi) in zip(v,y))
  tuple(args...)
end

function _new_arg(vi::AbstractArray,yi)
  dest = similar(vi)
  for i in eachindex(dest)
    dest[i] = yi
  end
  dest
end

_new_arg(vi,yi) = yi

"""
    testargs(f::Function,Ts::DataType...) -> Tuple

Returns a tuple with valid arguments of the types in `Ts` in order to call
function `f`. It defaults to `testvalues(Ts...)`, see the [`testvalues`](@ref)
function.
The user can overload the `testargs`
function for particular functions if the default test arguments are not in the domain
of the function and a `DomainError` is raised.

# Examples

For the following function, the default test argument (which is a zero)
is not in the domain. We can overload the `testargs` function to provide
a valid test argument.

```jldoctests
using InplaceArrays.Inference
import InplaceArrays.Inference: testargs
foo(x) = sqrt(x-1)
testargs(::typeof(foo),T::DataType) = (one(T),)
return_type(foo, Int)
# output
Float64
```

"""
testargs(f::Function,Ts...) = testvalues(Ts...)

"""
    testvalue(::Type{T}) where T

Returns an arbitrary instance of type `T`. It defaults to `zero(T)` for
non-array types and to an empty array for array types.
This function is used to compute the default test arguments in
[`testargs`](@ref).
It can be overloaded for new types `T` if `zero(T)` does not makes sense. 
"""
function testvalue end

testvalue(::Type{T}) where T = zero(T)

function testvalue(::Type{T}) where T<:AbstractArray{E,N} where {E,N}
   similar(T,fill(0,N)...)
end

"""
    testvalues(Ts::DataType...) -> Tuple

Returns a tuple with test values for each of the types in `Ts`.
Equivalent to `map(testvalue,Ts)`.
"""
function testvalues(a,b...)
  ta = testvalue(a)
  tb = testvalues(b...)
  (ta,tb...)
end

function testvalues(a)
  ta = testvalue(a)
  (ta,)
end

end # module
