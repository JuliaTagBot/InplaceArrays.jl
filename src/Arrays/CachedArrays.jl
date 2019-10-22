
"""
Type providing a re-sizable array that only allocates memory
when the underlying buffer needs to grow.
"""
mutable struct CachedArray{T,N,A<:AbstractArray{T,N}} <: AbstractArray{T,N}
  array::A
  size::NTuple{N,Int}
end

const CachedMatrix{T,A} = CachedArray{T,2,A}

const CachedVector{T,A} = CachedArray{T,1,A}

CachedArray(a::AbstractArray) = CachedArray(a,size(a))

CachedVector(a::AbstractVector) = CachedArray(a,size(a))

CachedMatrix(a::AbstractMatrix) = CachedArray(a,size(a))

function CachedArray(T,N)
  s = tuple([0 for i in 1:N]...)
  a = Array{T,N}(undef,s)
  CachedArray(a)
end

function CachedVector(T)
  CachedArray(T,1)
end

function CachedMatrix(T)
  CachedArray(T,2)
end

size(self::CachedArray) = self.size

function setsize!(self::CachedArray{T,N},s::NTuple{N,Int}) where {T,N}
  if s <= size(self.array)
    self.size = s
  else
    self.array = similar(self.array,T,s...)
    self.size = s
  end
end

@propagate_inbounds function getindex(self::CachedArray{T,N}, kj::Vararg{Integer,N}) where {T,N}
    self.array[kj...]
end

@propagate_inbounds function setindex!(B::CachedArray{T,N}, v, kj::Vararg{Integer,N}) where {T,N}
    B.array[kj...] = v
    v
end

function similar(::Type{CachedArray{T,N,A}},s::Tuple{Vararg{Int}}) where {T,N,A}
  a = similar(A,s)
  CachedArray(a)
end

