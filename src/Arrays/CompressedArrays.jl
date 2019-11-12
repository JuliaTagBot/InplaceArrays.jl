
"""
    struct CompressedArray{T,N,A,P} <: AbstractArray{T,N}
      values::A
      ptrs::P
    end
Type representing an array with a reduced set of values.
The array is represented by a short array of values, namely
the field `values`, and a large array of indices, namely the
field `ptrs`. The `i`-th component of the resulting array is
defined as `values[ptrs[i]]`. The type parameters `A`, and `P`
are restricted to be array types by the inner constructor of this `struct`.
"""
struct CompressedArray{T,N,A,P} <: AbstractArray{T,N}
  values::A
  ptrs::P
  @doc """
      CompressedArray(values::AbstractArray,ptrs::AbstractArray)

  Creates a `CompressedArray` object by the given arrays of `values` and 
  `ptrs`.
  """
  function CompressedArray(values::AbstractArray,ptrs::AbstractArray)
    A = typeof(values)
    P = typeof(ptrs)
    T = eltype(values)
    N = ndims(ptrs)
    new{T,N,A,P}(values,ptrs)
  end
end

size(a::CompressedArray) = size(a.ptrs)

@propagate_inbounds function getindex(a::CompressedArray,i::Integer)
  j = a.ptrs[i]
  a.values[j]
end

@propagate_inbounds function getindex(a::CompressedArray,i::Integer...)
  j = a.ptrs[i...]
  a.values[j]
end

function IndexStyle(a::Type{CompressedArray{T,N,A,P}}) where {T,N,A,P}
  IndexStyle(P)
end

function apply(f::Fill,g1::CompressedArray,g::CompressedArray...)
  if all( ( gi.ptrs === g1.ptrs for gi in g ) ) || all( ( gi.ptrs == g1.ptrs for gi in g ) )
    _apply_fill_compressed(f,g1,g...)
  else
    return AppliedArray(f,g1,g...)
  end
end

function _apply_fill_compressed(f,g1,g...)
  k = f.value
  ptrs = g1.ptrs
  vals = _getvalues(g1,g...)
  vk = apply(k,vals...)
  CompressedArray(collect(vk),ptrs)
end

function _getvalues(a,b...)
  va = a.values
  vb = _getvalues(b...)
  (va,vb...)
end

function _getvalues(a)
  va = a.values
  (va,)
end


