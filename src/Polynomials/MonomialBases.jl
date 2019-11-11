
"""
    struct MonomialBasis{...} <: Field

Type representing a basis of multivariate scalar-valued, vector-valued, or
tensor-valued, iso- or aniso-tropic monomials. The type parameters and fields of this `struct` are not public, they are 
private implementation details.  
This type fully implements the [`Field`](@ref) interface, with up to second order
derivatives.
"""
struct MonomialBasis{D,T} <: Field
  orders::NTuple{D,Int}
  terms::Vector{CartesianIndex{D}}
  function MonomialBasis{D}(
    ::Type{T}, orders::NTuple{D,Int}, terms::Vector{CartesianIndex{D}}) where {D,T}
    new{D,T}(orders,terms)
  end
end

"""
    MonomialBasis{D}(::Type{T}, orders::Tuple [, filter::Function]) where {D,T}

This version of the constructor allows to pass a tuple `orders` containing the
polynomial order to be used in each of the `D` dimensions in order to  construct
and anisotropic tensor-product space.
"""
function MonomialBasis{D}(
  ::Type{T}, orders::NTuple{D,Int}, filter::Function=_q_filter) where {D,T}

  terms = _define_terms(filter, orders)
  MonomialBasis{D}(T,orders,terms)
end

"""
    MonomialBasis{D}(::Type{T}, order::Int [, filter::Function]) where {D,T}

Returns an instance of `MonomialBasis` representing a multivariate polynomial basis
in `D` dimensions, of polynomial degree `order`, whose value is represented by the type `T`.
The type `T` is typically `<:Number`, e.g., `Float64` for scalar-valued functions and `VectorValue{D,Float64}`
for vector-valued ones.

# Filter function

The `filter` function is used to select which terms of the tensor product space
of order `order` in `D` dimensions are to be used. If the filter is not provided, the full tensor-product
space is used by default leading to a multivariate polynomial space of type Q.
The signature of the filter function is

    (e,order) -> Bool

where `e` is a tuple of `D` integers containing the exponents of a multivariate monomial. The following filters
are used to select well known polynomial spaces

- Q space: `(e,order) -> true`
- P space: `(e,order) -> sum(e) <= order`
- "Serendipity" space: `(e,order) -> sum( ( i for i in e if i>1 ) ) <= order`

"""
function MonomialBasis{D}(
  ::Type{T}, order::Int, filter::Function=_q_filter) where {D,T}

  orders = tfill(order,Val{D}())
  MonomialBasis{D}(T,orders,filter)
end

function field_cache(f::MonomialBasis{D,T},x) where {D,T}
  @assert D == length(eltype(x)) "Incorrect number of point components"
  np = length(x)
  ndof = length(f.terms)*n_components(T)
  n = 1 + maximum(f.orders)
  r = CachedArray(zeros(T,(np,ndof)))
  v = CachedArray(zeros(T,(ndof,)))
  c = CachedArray(zeros(eltype(T),(D,n)))
  (r, v, c)
end

function evaluate_field!(cache,f::MonomialBasis{D,T},x) where {D,T}
  r, v, c = cache
  np = length(x)
  ndof = length(f.terms)*n_components(T)
  n = 1 + maximum(f.orders)
  setsize!(r,(np,ndof))
  setsize!(v,(ndof,))
  setsize!(c,(D,n))
  for i in 1:np
    @inbounds xi = x[i]
    _evaluate_nd!(v,xi,f.orders,f.terms,c)
    for j in 1:ndof
      @inbounds r[i,j] = v[j]
    end
  end
  r.array
end

function gradient_cache(f::MonomialBasis{D,V},x) where {D,V}
  @assert D == length(eltype(x)) "Incorrect number of point components"
  np = length(x)
  ndof = length(f.terms)*n_components(V)
  xi = testitem(x)
  T = gradient_type(V,xi)
  n = 1 + maximum(f.orders)
  r = CachedArray(zeros(T,(np,ndof)))
  v = CachedArray(zeros(T,(ndof,)))
  c = CachedArray(zeros(eltype(T),(D,n)))
  g = CachedArray(zeros(eltype(T),(D,n)))
  (r, v, c, g)
end

function evaluate_gradient!(cache,f::MonomialBasis{D,T},x) where {D,T}
  r, v, c, g = cache
  np = length(x)
  ndof = length(f.terms) * n_components(T)
  n = 1 + maximum(f.orders)
  setsize!(r,(np,ndof))
  setsize!(v,(ndof,))
  setsize!(c,(D,n))
  setsize!(g,(D,n))
  for i in 1:np
    @inbounds xi = x[i]
    _gradient_nd!(v,xi,f.orders,f.terms,c,g,T)
    for j in 1:ndof
      @inbounds r[i,j] = v[j]
    end
  end
  r.array
end

function hessian_cache(f::MonomialBasis{D,V},x) where {D,V}
  @assert D == length(eltype(x)) "Incorrect number of point components"
  np = length(x)
  ndof = length(f.terms)*n_components(V)
  xi = testitem(x)
  T = gradient_type(gradient_type(V,xi),xi)
  n = 1 + maximum(f.orders)
  r = CachedArray(zeros(T,(np,ndof)))
  v = CachedArray(zeros(T,(ndof,)))
  c = CachedArray(zeros(eltype(T),(D,n)))
  g = CachedArray(zeros(eltype(T),(D,n)))
  h = CachedArray(zeros(eltype(T),(D,n)))
  (r, v, c, g, h)
end

function evaluate_hessian!(cache,f::MonomialBasis{D,T},x) where {D,T}
  r, v, c, g, h = cache
  np = length(x)
  ndof = length(f.terms) * n_components(T)
  n = 1 + maximum(f.orders)
  setsize!(r,(np,ndof))
  setsize!(v,(ndof,))
  setsize!(c,(D,n))
  setsize!(g,(D,n))
  setsize!(h,(D,n))
  for i in 1:np
    @inbounds xi = x[i]
    _hessian_nd!(v,xi,f.orders,f.terms,c,g,h,T)
    for j in 1:ndof
      @inbounds r[i,j] = v[j]
    end
  end
  r.array
end

# Helpers

_q_filter(e,o) = true

function _define_terms(filter,orders)
  t = orders .+ 1
  g = (0 .* orders) .+ 1
  cis = CartesianIndices(t)
  co = CartesianIndex(g)
  maxorder = maximum(orders)
  [ ci for ci in cis if filter(Tuple(ci-co),maxorder) ]
end

function _evaluate_1d!(v::AbstractMatrix{T},x,order,d) where T
  n = order + 1
  z = one(T)
  @inbounds v[d,1] = z
  for i in 2:n
    @inbounds v[d,i] = x[d]^(i-1)
  end
end

function _gradient_1d!(v::AbstractMatrix{T},x,order,d) where T
  n = order + 1
  z = zero(T)
  @inbounds v[d,1] = z
  for i in 2:n
    @inbounds v[d,i] = (i-1)*x[d]^(i-2)
  end
end

function _hessian_1d!(v::AbstractMatrix{T},x,order,d) where T
  n = order + 1
  z = zero(T)
  @inbounds v[d,1] = z
  if n>1
    @inbounds v[d,2] = z
  end
  for i in 3:n
    @inbounds v[d,i] = (i-1)*(i-2)*x[d]^(i-3)
  end
end

function _evaluate_nd!(
  v::AbstractVector{V},
  x,
  orders,
  terms::AbstractVector{CartesianIndex{D}},
  c::AbstractMatrix{T}) where {V,T,D}

  dim = D
  for d in 1:dim
    _evaluate_1d!(c,x,orders[d],d)
  end

  o = one(T)
  k = 1

  for ci in terms

    s = o
    for d in 1:dim
      @inbounds s *= c[d,ci[d]]
    end

    k = _set_value!(v,s,k)

  end

end

@inline function _set_value!(v::AbstractVector{V},s::T,k) where {V,T}
  m = zero(mutable(V))
  z = zero(T)
  js = eachindex(m)
  for j in js
    for i in js
      @inbounds m[i] = z
    end
    m[j] = s
    v[k] = m
    k += 1
  end
  k
end

@inline function _set_value!(v::AbstractVector{<:Real},s,k)
    @inbounds v[k] = s
    k+1
end

function _gradient_nd!(
  v::AbstractVector{G},
  x,
  orders,
  terms::AbstractVector{CartesianIndex{D}},
  c::AbstractMatrix{T},
  g::AbstractMatrix{T},
  ::Type{V}) where {G,T,D,V}

  dim = D
  for d in 1:dim
    _evaluate_1d!(c,x,orders[d],d)
    _gradient_1d!(g,x,orders[d],d)
  end

  z = zero(mutable(VectorValue{D,T}))
  o = one(T)
  k = 1

  for ci in terms

    s = z
    for i in eachindex(s)
      @inbounds s[i] = o
    end
    for q in 1:dim
      for d in 1:dim
        if d != q
          @inbounds s[q] *= c[d,ci[d]]
        else
          @inbounds s[q] *= g[d,ci[d]]
        end
      end
    end

    k = _set_gradient!(v,s,k,V)

  end

end

@inline function _set_gradient!(
  v::AbstractVector{G},s,k,::Type{<:Real}) where G

  @inbounds v[k] = s
  k+1
end

@inline function _set_gradient!(
  v::AbstractVector{G},s,k,::Type{V}) where {V,G}

  T = eltype(s)
  m = zero(mutable(G))
  w = zero(V)
  z = zero(T)
  for j in CartesianIndices(w)
    for i in CartesianIndices(m)
     @inbounds m[i] = z
    end
    for i in CartesianIndices(s)
      @inbounds m[i,j] = s[i]
    end
    @inbounds v[k] = m
    k += 1
  end
  k
end

function _hessian_nd!(
  v::AbstractVector{G},
  x,
  orders,
  terms::AbstractVector{CartesianIndex{D}},
  c::AbstractMatrix{T},
  g::AbstractMatrix{T},
  h::AbstractMatrix{T},
  ::Type{V}) where {G,T,D,V}

  dim = D
  for d in 1:dim
    _evaluate_1d!(c,x,orders[d],d)
    _gradient_1d!(g,x,orders[d],d)
    _hessian_1d!(h,x,orders[d],d)
  end

  z = zero(mutable(TensorValue{D,T,D*D}))
  o = one(T)
  k = 1

  for ci in terms

    s = z
    for i in eachindex(s)
      @inbounds s[i] = o
    end
    for r in 1:dim
      for q in 1:dim
        for d in 1:dim
          if d != q && d != r
            @inbounds s[r,q] *= c[d,ci[d]]
          elseif d == q && d ==r
            @inbounds s[r,q] *= h[d,ci[d]]
          else
            @inbounds s[r,q] *= g[d,ci[d]]
          end
        end
      end
    end

    k = _set_gradient!(v,s,k,V)

  end

end

