
"""
    abstract type Polytope{D}

Abstract type representing a polytope (i.e., a polyhedron in arbitrary dimensions).
`D` is the environment dimension (typically, 0, 1, 2, or 3).
This type parameter is needed since there are functions in the 
`Polytope` interface that return containers with `Point{D}` objects.
We adopt the [usual nomenclature](https://en.wikipedia.org/wiki/Polytope) for polytope-related objects.
All objects in a polytope (from vertices to the polytope itself) are called *n-faces* or simply *faces*.
The notation *n-faces* is used only when it is needed to refer to the object dimension n. Otherwise we simply
use *face*. In addition, we say

- vertex (pl. vertices): for 0-faces
- edge: for 1-faces
- facet: for (`D-1`)-faces

The `Polytope` interface is defined by overloading the following functions

- [`polytope_faces(p::Polytope)`](@ref)
- [`polytope_dimrange(p::Polytope)`](@ref)
- [`Polytope{N}(p::Polytope,faceid::Integer) where N`](@ref)
- [`vertex_coordinates(p::Polytope)`](@ref)
- [`(==)(a::Polytope{D},b::Polytope{D}) where D`](@ref)

And optionally these ones:

- [`edge_tangents(p::Polytope)`](@ref)
- [`facet_normals(p::Polytope)`](@ref)
- [`facet_orientations(p::Polytope)`](@ref)
- [`vertex_permutations(p::Polytope)`](@ref)
- [`polytope_vtkid(p::Polytope)`](@ref)
- [`polytope_vtknodes(p::Polytope)`](@ref)

The interface can be tested with the function

- [`test_polytope`](@ref)

"""
abstract type Polytope{D} end

# Mandatory

"""
    polytope_faces(p::Polytope) -> Vector{Vector{Int}}

Given a polytope `p` the function returns a vector of vectors
defining the *incidence* relation of the faces in the polytope.

Each face in the polytope receives a unique integer id. The id 1 is assigned
to the first 0-face. Consecutive increasing ids are assigned to the other
0-faces, then to 1-faces, and so on. The polytope itself receives the largest id
which coincides with `num_faces(p)`. For a face id `iface`, `polytope_faces(p)[iface]`
is a vector of face ids, corresponding to the faces that are *incident* with the face
labeled with `iface`. That is, faces that are either on its boundary or the face itself. 
In this vector of incident face ids, faces are ordered by dimension, starting with 0-faces.
Within each dimension, the labels are ordered in a consistent way with the polyope object
for the face `iface` itself.

# Examples

```jldoctest
using InplaceArrays.ReferenceFEs

faces = polytope_faces(SEGMENT)
println(faces)

# output
Array{Int64,1}[[1], [2], [1, 2, 3]]
```

The constant [`SEGMENT`](@ref) is bound to a predefined instance of polytope
that represents a segment.
The face labels associated with a segment are `[1,2,3]`, being `1` and `2` for the vertices and 
`3` for the segment itself. In this case, this function would return the vector of vectors
`[[1],[2],[1,2,3]]` meaning that vertex `1` is incident with vertex `1` (idem for vertex 2), and that 
the segment (id `3`) is incident with the vertices `1` and `2` and the segment itself.

"""
function polytope_faces(p::Polytope)
  @abstractmethod
end

"""
    polytope_dimrange(p::Polytope) -> Vector{UnitRange{Int}}

Given a polytope `p` it returns a vector of ranges. The entry `d+1` in this vector
contains the range of face ids for the faces of dimension `d`.

# Examples

```jldoctest
using InplaceArrays.ReferenceFEs

ranges = polytope_dimrange(SEGMENT)
println(ranges)

# output
UnitRange{Int64}[1:2, 3:3]
```
Face ids for the vertices in the segment range from 1 to 2 (2 vertices),
the face ids for edges in the segment range from 3 to 3 (only one edge with id 3).

"""
function polytope_dimrange(p::Polytope)
  @abstractmethod
end

"""
    Polytope{N}(p::Polytope,faceid::Integer) where N

Returns a `Polytope{N}` object representing the "reference" polytope of the `N`-face with id `faceid`.
The value `faceid` refers to the numeration restricted to the dimension `N`
(it starts with 1 for the first `N`-face).
"""
function Polytope{D}(p::Polytope,Dfaceid::Integer) where D
  @abstractmethod
end

"""
    vertex_coordinates(p::Polytope) -> Vector{Point{D,Float64}}

Given a polytope `p` return a vector of points
representing containing the coordinates of the vertices.
"""
function vertex_coordinates(p::Polytope)
  @abstractmethod
end

"""
    (==)(a::Polytope{D},b::Polytope{D}) where D

Returns `true` if the polytopes `a` and `b` are equivalent. Otherwise, it 
returns `false`.
Note that the operator `==` returns `false` by default for polytopes
of different dimensions. Thus, this function has to be overloaded only
for the case of polytopes `a` and `b` of same dimension.
"""
function (==)(a::Polytope{D},b::Polytope{D}) where D
  @abstractmethod
end

function (==)(a::Polytope,b::Polytope)
  false
end

# Optional

"""
    edge_tangents(p::Polytope) -> Vector{VectorValue{D,Float64}}

Given a polytope `p`, returns a vector of `VectorValue` objects
representing the unit tangent vectors to the polytope edges.
"""
function edge_tangents(p::Polytope)
  @abstractmethod
end

"""
    facet_normals(p::Polytope) -> Vector{VectorValue{D,Float64}}

Given a polytope `p`, returns a vector of `VectorValue` objects
representing the unit outward normal vectors to the polytope facets.
"""
function facet_normals(p::Polytope)
  @abstractmethod
end

"""
    facet_orientations(p::Polytope) -> Vector{Int}

Given a polytope `p` returns a vector of integers of length `num_facets(p)`.
Facets, whose vertices are ordered consistently with the
outwards normal vector, receive value `1` in this vector. Otherwise, facets
receive value `-1`.
"""
function facet_orientations(p::Polytope)
  @abstractmethod
end

"""
    vertex_permutations(p::Polytope) -> Vector{Vector{Int}}

Given a polytope `p`, returns a vector of vectors containing all admissible permutations
of the polytope vertices. An admissible permutation is one such that, if the vertices of the polytope
are re-labeled according to this permutation, the resulting polytope preserves the shape of the
original one.

# Examples

```jldoctest
using InplaceArrays.ReferenceFEs

perms = vertex_permutations(SEGMENT)
println(perms)

# output
Array{Int64,1}[[1, 2], [2, 1]]

```
The first admissible permutation for a segment is `[1,2]`,i.e., the identity.
The second one is `[2,1]`, i.e., the first vertex is relabeled as `2` and the
second vertex is relabeled as `1`.

"""
function vertex_permutations(p::Polytope)
  @abstractmethod
end

"""
    polytope_vtkid(p::Polytope) -> Int

Given a polytope `p`, returns an integer with its vtk identifier.
Overloading of this function is needed only in order to visualize the underlying polytope
with Paraview.
"""
function polytope_vtkid(p::Polytope)
  @abstractmethod
end

"""
    polytope_vtknodes(p::Polytope) -> Vector{Int}

Given a polytope `p`, returns a vector of integers representing a permutation of the
polytope vertices required to relabel the vertices according the criterion adopted in
Paraview.
Overloading of this function is needed only in order to visualize the underlying polytope
with Paraview.
"""
function polytope_vtknodes(p::Polytope)
  @abstractmethod
end

# Some generic API

num_dims(::Type{<:Polytope{D}}) where D = D

"""
    num_dims(::Type{<:Polytope{D}}) where D
    num_dims(p::Polytope{D}) where D

Returns `D`. 
"""
num_dims(p::Polytope) = num_dims(typeof(p))

"""
    num_faces(p::Polytope)

Returns the total number of faces in polytope `p` (from vertices to the polytope itself).
"""
function num_faces(p::Polytope)
  length(polytope_faces(p))
end

"""
    num_faces(p::Polytope,dim::Integer)

Returns the number of faces of dimension `dim` in polytope `p`.
"""
function num_faces(p::Polytope,dim::Integer)
  length(polytope_dimrange(p)[dim+1])
end

"""
    num_facets(p::Polytope)

Returns the number of facets in the polytope `p`.
"""
function num_facets(p::Polytope)
  D = num_dims(p)
  if D > 0
    num_faces(p,D-1)
  else
    0
  end
end

"""
    num_edges(p::Polytope)

Returns the number of edges in the polytope `p`.
"""
function num_edges(p::Polytope)
  D = num_dims(p)
  if D > 0
    num_faces(p,1)
  else
    0
  end
end

"""
    num_vertices(p::Polytope)

Returns the number of vertices in the polytope `p`.
"""
function num_vertices(p::Polytope)
  num_faces(p,0)
end

"""
    polytope_facedims(p::Polytope) -> Vector{Int}

Given a polytope `p`, returns a vector indicating
the dimension of each face in the polytope

# Examples

```jldoctest
using InplaceArrays.ReferenceFEs

dims = polytope_facedims(SEGMENT)
println(dims)

# output
[0, 0, 1]

```

The first two faces in the segment (the two vertices) have dimension 0 and the 
third face (the segment itself) has dimension 1

"""
function polytope_facedims(p::Polytope)
  n = num_faces(p)
  facedims = zeros(Int,n)
  dimrange = polytope_dimrange(p)
  for (i,r) in enumerate(dimrange)
    d = i-1
    facedims[r] .= d
  end
  facedims
end

"""
    polytope_offsets(p::Polytope) -> Vector{Int}

Given a polytope `p`, it returns a vector of integers. The position in
the `d+1` entry in this vector is the offset that transforms a face id in
the global numeration in the polytope to the numeration restricted to faces
to dimension `d`.

# Examples

```jldoctest
using InplaceArrays.ReferenceFEs

offsets = polytope_offsets(SEGMENT)
println(offsets)

# output
[0, 2]

```
"""
function polytope_offsets(p::Polytope)
  D = num_dims(p)
  dimrange = polytope_dimrange(p)
  offsets = zeros(Int,D+1)
  k = 0
  for i in 0:D
    d = i+1
    offsets[d] = k
    r = dimrange[d]
    k += length(r)
  end
  offsets
end

"""
    polytope_offset(p::Polytope,d::Integer)

Equivalent to `polytope_offsets(p)[d+1]`.
"""
function polytope_offset(p::Polytope,d::Integer)
  polytope_offsets(p)[d+1]
end

"""
    polytope_faces(p::Polytope,dimfrom::Integer,dimto::Integer) -> Vector{Vector{Int}}

For `dimfrom >= dimto` returns a vector that for each face of
dimension `dimfrom` stores a vector of the ids of faces of
dimension `dimto` on its boundary.

For `dimfrom < dimto` returns a vector that for each face of `dimfrom`
stores a vector of the face ids of faces of dimension `dimto` that touch it.

The numerations used in this funcitons are the ones restricted to each dimension.

```jldoctest
using InplaceArrays.ReferenceFEs

edge_to_vertices = polytope_faces(QUAD,1,0)
println(edge_to_vertices)

vertex_to_edges_around = polytope_faces(QUAD,0,1)
println(vertex_to_edges_around)

# output
Array{Int64,1}[[1, 2], [3, 4], [1, 3], [2, 4]]
Array{Int64,1}[[1, 3], [1, 4], [2, 3], [2, 4]]
```
"""
function polytope_faces(p::Polytope,dimfrom::Integer,dimto::Integer)
  if dimfrom >= dimto
    _polytope_faces_primal(p,dimfrom,dimto)
  else
    _polytope_faces_dual(p,dimfrom,dimto)
  end
end

function _polytope_faces_primal(p,dimfrom,dimto)
  dimrange = polytope_dimrange(p)
  r = dimrange[dimfrom+1]
  faces = polytope_faces(p)
  faces_dimfrom = faces[r]
  n = length(faces_dimfrom)
  faces_dimfrom_dimto = Vector{Vector{Int}}(undef,n)
  offset = polytope_offset(p,dimto)
  for i in 1:n
    f = Polytope{dimfrom}(p,i)
    rto = polytope_dimrange(f)[dimto+1]
    faces_dimfrom_dimto[i] = faces_dimfrom[i][rto].-offset
  end
  faces_dimfrom_dimto
end

function _polytope_faces_dual(p,dimfrom,dimto)
  tface_to_ffaces = polytope_faces(p,dimto,dimfrom)
  nffaces = num_faces(p,dimfrom)
  fface_to_tfaces = [Int[] for in in 1:nffaces]
  for (tface,ffaces) in enumerate(tface_to_ffaces)
    for fface in ffaces
      push!(fface_to_tfaces[fface],tface)
    end
  end
  fface_to_tfaces
end

# Testers

"""
    test_polytope(p::Polytope{D}; optional::Bool=false) where D

Function that stresses out the functions in the `Polytope` interface.
It tests whether the function in the polytope interface are defined
for the given object, and whether they return objects of the expected type.
With `optional=false` (the default), only the mandatory functions are checked.
With `optional=true`, the optional functions are also tested except
`polytope_vtkid`  and `polytope_vtknodes`.
"""
function test_polytope(p::Polytope{D};optional::Bool=false) where D
  @test D == num_dims(p)
  faces = polytope_faces(p)
  @test isa(faces,Vector{Vector{Int}})
  @test num_faces(p) == length(faces)
  offsets = polytope_offsets(p)
  @test isa(offsets,Vector{Int})
  @test length(offsets) == D+1
  dimrange = polytope_dimrange(p)
  @test isa(dimrange,Vector{UnitRange{Int}})
  @test length(dimrange) == D+1
  @test p == p
  for d in 0:D
    for id in 1:num_faces(p,d)
      pd = Polytope{d}(p,id)
      @test isa(pd,Polytope{d})
    end
  end
  for dimfrom in 0:D
    for dimto in 0:D
      fs = polytope_faces(p,dimfrom,dimto)
      @test isa(fs,Vector{Vector{Int}})
    end
  end
  x = vertex_coordinates(p)
  @test isa(x,Vector{Point{D,Float64}})
  @test length(x) == num_faces(p,0)
  if optional
    fn = facet_normals(p)
    @test isa(fn,Vector{VectorValue{D,Float64}})
    @test length(fn) == num_facets(p)
    or = facet_orientations(p)
    @test isa(or,Vector{Int})
    @test length(or) == num_facets(p)
    et = edge_tangents(p)
    @test isa(et,Vector{VectorValue{D,Float64}})
    @test length(et) == num_edges(p)
    perm = vertex_permutations(p)
    @test isa(perm,Vector{Vector{Int}})
  end
end

