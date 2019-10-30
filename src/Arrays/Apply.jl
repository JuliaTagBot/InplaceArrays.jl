
"""
    apply(f,a::AbstractArray...) -> AbstractArray

Applies the kernel `f` to the entries of the arrays in `a` (see the definition of [`Kernel`](@ref)).

The resulting array `r` is such that `r[i]` equals to `apply_kernel(f,ai...)` where `ai`
is the tuple containing the `i`-th entry of the arrays in `a` (see function
[`apply_kernel`](@ref) for more details).
In other words, the resulting array is numerically equivalent to:

    map( (x...)->apply_kernel(f,x...), a...)

"""
function apply(f,a::AbstractArray...)
  s = common_size(a...)
  apply(Fill(f,s...),a...)
end

"""
    apply(f::AbstractArray,a::AbstractArray...) -> AbstractArray
Applies the kernels in the array of kernels `f` to the entries in the arrays in `a`.

The resulting array has the same entries as the one obtained with:

    map( apply_kernel, f, a...)

"""
function apply(f::AbstractArray,a::AbstractArray...)
  AppliedArray(f,a...)
end

#function apply(f::AbstractArray{<:Number},a::AbstractArray...)
#  f
#end
#
#function apply(f::AbstractArray{<:AbstractArray},a::AbstractArray...)
#  f
#end

"""
    apply_all(f::Tuple,a::AbstractArray...) -> Tuple

Numerically equivalent to 

    tuple( ( apply(fi, a...) for fi in f)... )
"""
function apply_all(f::Tuple,a::AbstractArray...)
  _apply_several(a,f...)
end

function _apply_several(a,f,g...)
  fa = apply(f,a...)
  ga = _apply_several(a,g...)
  (fa,ga...)
end

function _apply_several(a,f)
  fa = apply(f,a...)
  (fa,)
end

# Helpers

struct AppliedArray{T,N,F,G} <: AbstractArray{T,N}
  g::G
  f::F
  size::NTuple{N,Int}
  function AppliedArray(g::AbstractArray,f::AbstractArray...)
    G = typeof(g)
    F = typeof(f)
    gi = testitem(g) #Assumes that all kernels return the same type
    fi = testitems(f...)
    T = kernel_return_type(gi,fi...)
    N, s = _prepare_shape(g,f...)
    new{T,N,F,G}(g,f,s)
  end
end

function uses_hash(::Type{<:AppliedArray})
  Val(true)
end

function array_cache(hash::Dict,a::AppliedArray)
    id = objectid(a)
    _cache = _array_cache(hash,a)
    if haskey(hash,id)
      cache = _get_stored_cache(_cache,hash,id)
    else
      cache = _cache
      hash[id] = cache
    end
    cache
end

#TODO
@static if VERSION >= v"1.1"
  @noinline function _get_stored_cache(cache::T,hash,id) where T
    c::T = hash[id]
    c
  end
else
  @noinline function _get_stored_cache(cache::T,hash,id) where T
    hash[id]
  end
end

function _array_cache(hash,a::AppliedArray)
  cg = array_cache(hash,a.g)
  gi = testitem(a.g)
  fi = testitems(a.f...)
  cf = array_caches(hash,a.f...)
  cgi = kernel_cache(gi,fi...)
  ai = apply_kernel!(cgi,gi,fi...)
  i = -testitem(eachindex(a))
  e = Evaluation((i,),ai)
  c = (cg, cgi, cf)
  (c,e)
end

function getindex!(cache,a::AppliedArray,i::Integer...)
  li = LinearIndices(a)
  getindex!(cache,a,li[i...])
end

function getindex!(cache,a::AppliedArray,i::Integer)
  _cached_getindex!(cache,a,(i,))
end

function getindex!(cache,a::AppliedArray,i::CartesianIndex)
  _cached_getindex!(cache,a,Tuple(i))
end

function _cached_getindex!(cache,a::AppliedArray,i::Tuple)
  c, e = cache
  v = e.fx
  if e.x != i
    v = _getindex!(c,a,i...)
    e.x = i
    e.fx = v
  end
   v
end

function _getindex!(cache,a::AppliedArray,i...)
  cg, cgi, cf = cache
  gi = getindex!(cg,a.g,i...)
  fi = getitems!(cf,a.f,i...)
  vi = apply_kernel!(cgi,gi,fi...)
  vi
end

function Base.getindex(a::AppliedArray,i...)
  ca = array_cache(a)
  getindex!(ca,a,i...)
end

function Base.IndexStyle(
  ::Type{AppliedArray{T,N,F,G}}) where {T,N,F,G}
  common_index_style(F)
end

Base.size(a::AppliedArray) = a.size

function _prepare_shape(a...)
  s = common_size(a...)
  N = length(s)
  (N,s)
end

function common_size(a::AbstractArray...)
  a1, = a
  c = all([size(a1) == size(ai) for ai in a])
  if !c
    error("Array sizes $(map(size,a)) are not compatible.")
  end
  s = size(a1)
  s
end

#TODO not sure what to do with shape and index-style
function common_index_style(::Type{<:Tuple})
  IndexLinear()
end

mutable struct Evaluation{X,F}
  x::X
  fx::F
  function Evaluation(x::X,fx::F) where {X,F}
    new{X,F}(x,fx)
  end
end

# Particular implementations for Fill

function apply(f::Fill,a::Fill...)
  ai = getvalues(a...)
  r = apply_kernel(f.value,ai...)
  s = common_size(f,a...)
  Fill(r,s)
end

function getvalues(a::Fill,b::Fill...)
  ai = a.value
  bi = getvalues(b...)
  (ai,bi...)
end

function getvalues(a::Fill)
  ai = a.value
  (ai,)
end

# TODO Implement Compressed
# TODO Think about iteration and sub-iteration

