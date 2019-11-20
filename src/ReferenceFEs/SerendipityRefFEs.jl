
"""
    SerendipityRefFE(::Type{T},p::Polytope,order::Int) where T

Returns an instance of `LagrangianRefFE`, whose underlying approximation space
is the serendipity space of order `order`. Implemented for order from 1 to 4.
The type of the polytope `p` has to implement all the queries detailed in the
constructor [`LagrangianRefFE(::Type{T},p::Polytope{D},orders) where {T,D}`](@ref)
plus this additional method:

- [`is_serendipity_compatible(p::Polytope)`](@ref)

# Examples

```jldoctest
using InplaceArrays.ReferenceFEs

order = 2
reffe = SerendipityRefFE(Float64,QUAD,order)

println( num_dofs(reffe) )

# output
8

```
"""
function SerendipityRefFE(::Type{T},p::Polytope,order::Int) where T
  @assert is_serendipity_compatible(p) "Polytope not compatible with serendipity elements"
  if order > 0
    sp = SerendipityPolytope(p) 
  else
    sp = p
  end
  LagrangianRefFE(T,sp,order)
end

"""
    is_serendipity_compatible(p::Polytope) -> Bool

Returns `true` if the polytope `p` is compatible with the
serendipity space (i.e., it is a n-cube). This method is implemented
for `ExtrusionPolytope`, and should be implemented by new
polytope types if they are to be used to build serendipity spaces.
"""
function is_serendipity_compatible(p::Polytope)
  @abstractmethod
end

# Concrete implementation for ExtrusionPolytope

function is_serendipity_compatible(p::ExtrusionPolytope)
  all(p.extrusion.array .== HEX_AXIS)
end


# Helper private type
struct SerendipityPolytope{D,P} <: Polytope{D}
  hex::P
  SerendipityPolytope(p::Polytope{D}) where D = new{D,typeof(p)}(p)
end

# Implemented polytope interface

function get_faces(p::SerendipityPolytope)
  get_faces(p.hex)
end

function get_dimrange(p::SerendipityPolytope)
  get_dimrange(p.hex)
end

function Polytope{N}(p::SerendipityPolytope,Nfaceid::Integer) where N
  face_hex = Polytope{N}(p.hex, Nfaceid)
  SerendipityPolytope(face_hex)
end

function Polytope{D}(p::SerendipityPolytope{D},Dfaceid::Integer) where D
  @assert Dfaceid == 1 "Only one D-face"
  p
end

function get_vertex_coordinates(p::SerendipityPolytope)
  get_vertex_coordinates(p.hex)
end

function (==)(a::SerendipityPolytope{D},b::SerendipityPolytope{D}) where D
  a.hex == b.hex
end

function get_vertex_permutations(p::SerendipityPolytope)
  get_vertex_permutations(p.hex)
end

# Implemented polytope interface for LagrangianRefFEs

function _s_filter(e,order)
  sum( [ i for i in e if i>1 ] ) <= order
end

function compute_monomial_basis(::Type{T},p::SerendipityPolytope{D},orders) where {T,D}
  MonomialBasis{D}(T,orders,_s_filter)
end

function compute_own_nodes(p::SerendipityPolytope{0},orders)
  compute_own_nodes(p.hex,orders)
end

function compute_own_nodes(p::SerendipityPolytope{1},orders)
  compute_own_nodes(p.hex,orders)
end

function compute_own_nodes(p::SerendipityPolytope{2},orders)
  order, = orders
  if order == 4
    o = (2,2)
  elseif order in (0,1,2,3)
    o=(1,1)
  else
    @unreachable "Serendipity elements only up to order 4"
  end
  compute_own_nodes(p.hex,o)
end

function compute_own_nodes(p::SerendipityPolytope{3},orders)
  Point{3,Float64}[]
end

function compute_own_nodes(p::SerendipityPolytope,orders)
  @unreachable "Serendipity elements only up to 3d"
end

function compute_face_orders(
  p::SerendipityPolytope{D},face::SerendipityPolytope{N},iface::Int,orders) where {D,N}
  compute_face_orders(p.hex,face.hex,iface,orders)
end

