
"""
"""
function integrate(f,x,w,j)
  fx = evaluate_field(f,x)
  jx = evaluate_field(j,x)
  k = IntKernel()
  apply_kernel(k,fx,w,jx)
end

"""
"""
function integrate(
  f::AbstractArray,x,w,j)
  fx = evaluate(f,x)
  jx = evaluate(j,x)
  k = IntKernel()
  apply(k,fx,w,jx)
end

struct IntKernel <: Kernel end

function kernel_cache(k::IntKernel,f::AbstractVector,w,j)
  _integrate_checks(f,w,j)
  _integrate_rt(f,w,j)
end

@inline function apply_kernel!(T,k::IntKernel,f::AbstractVector,w,j)
  _integrate_checks(f,w,j)
  r = zero(T)
  np = length(f)
  for p in 1:np
    @inbounds r += f[p]*w[p]*meas(j[p])
  end
  r
end

function kernel_cache(k::IntKernel,f::AbstractArray,w,j)
  _integrate_checks(f,w,j)
  T = _integrate_rt(f,w,j)
  _, s = _split(size(f)...)
  r = zeros(T,s)
  c = CachedArray(r)
end

@inline function apply_kernel!(c,k::IntKernel,f::AbstractArray,w,j)
  _integrate_checks(f,w,j)
  np, s = _split(size(f)...)
  cis = CartesianIndices(s)
  setsize!(c,s)
  for p in 1:np
    @inbounds dV = w[p]*meas(j[p])
    for i in cis
      @inbounds c[i] += f[p,i]*dV
    end
  end
  c
end

function _integrate_rt(f,w,j)
  Tf = eltype(f)
  Tw = eltype(w)
  Tj = eltype(j)
  return_type(*,Tf,Tw,return_type(meas,Tj))
end

function _integrate_checks(f,w,j)
  nf, = size(f)
  nw = length(w)
  nj = length(j)
  @assert (nf == nw) && (nw == nj) "integrate: sizes  mismatch."
end
