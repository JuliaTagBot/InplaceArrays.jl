module PolytopesTests

using Test
using LinearAlgebra
using InplaceArrays.Helpers
using InplaceArrays.TensorValues
using InplaceArrays.Arrays
using InplaceArrays.Fields
using InplaceArrays.ReferenceFEs

import InplaceArrays.ReferenceFEs: Polytope
import InplaceArrays.ReferenceFEs: polytope_faces
import InplaceArrays.ReferenceFEs: polytope_dimrange
import InplaceArrays.ReferenceFEs: vertex_coordinates
import Base: ==

struct MockVertex <: Polytope{0} end

polytope_faces(p::MockVertex) = [[1]]

polytope_dimrange(p::MockVertex) = [1:1]

function Polytope{0}(p::MockVertex,faceid)
  @assert faceid == 1
  p
end

function (==)(a::MockVertex,b::MockVertex)
  true
end

vertex_coordinates(p::MockVertex) = [zero(Point{0,Float64})]

struct MockSegment <: Polytope{1} end

polytope_faces(p::MockSegment) = [[1],[2],[1,2,3]]

polytope_dimrange(p::MockSegment) = [1:2,3:3]

function Polytope{0}(p::MockSegment,faceid)
  @assert faceid in 1:2
  MockVertex()
end

function Polytope{1}(p::MockSegment,faceid)
  @assert faceid == 1
  p
end

function (==)(a::MockSegment,b::MockSegment)
  true
end

vertex_coordinates(p::MockSegment) = Point{1,Float64}[(0),(1)]

struct MockQuad <: Polytope{2} end

function polytope_faces(p::MockQuad)
  [
    [1],[2],[3],[4],
    [1,2,5],[3,4,6],[1,3,7],[2,4,8],
    [1,2,3,4,5,6,7,8,9]
  ]
end

function polytope_dimrange(p::MockQuad)
  [1:4,5:8,9:9]
end

function Polytope{0}(p::MockQuad,faceid)
  @assert faceid in 1:4
  MockVertex()
end

function Polytope{1}(p::MockQuad,faceid)
  @assert faceid in 1:4
  MockSegment()
end

function Polytope{2}(p::MockQuad,faceid)
  @assert faceid == 1
  p
end

function (==)(a::MockQuad,b::MockQuad)
  true
end

vertex_coordinates(p::MockQuad) = Point{2,Float64}[(0,0),(1,0),(0,1),(1,1)]

v = MockVertex()
test_polytope(v)
@test polytope_faces(v,0,0) == [[1]]
@test polytope_facedims(v) == [0]
@test polytope_offsets(v) == [0]
@test num_facets(v) == 0
@test num_edges(v) == 0

s = MockSegment()
test_polytope(s)
@test polytope_faces(s,0,0) == [[1], [2]]
@test polytope_faces(s,1,0) == [[1, 2]]
@test polytope_faces(s,0,1) == [[1], [1]]
@test polytope_faces(s,1,1) == [[1]]
@test polytope_facedims(s) == [0,0,1]
@test polytope_offsets(s) == [0,2]
@test num_facets(s) == 2
@test num_edges(s) == 1

q = MockQuad()
test_polytope(q)
@test polytope_faces(q,0,0) == [[1], [2], [3], [4]]
@test polytope_faces(q,1,0) == [[1, 2], [3, 4], [1, 3], [2, 4]]
@test polytope_faces(q,2,0) == [[1, 2, 3, 4]]
@test polytope_faces(q,0,1) == [[1, 3], [1, 4], [2, 3], [2, 4]]
@test polytope_faces(q,1,1) == [[1], [2], [3], [4]]
@test polytope_faces(q,2,1) == [[1, 2, 3, 4]]
@test polytope_faces(q,0,2) == [[1], [1], [1], [1]]
@test polytope_faces(q,1,2) == [[1], [1], [1], [1]]
@test polytope_faces(q,2,2) == [[1]]
@test polytope_facedims(q) == [0,0,0,0,1,1,1,1,2]
@test polytope_offsets(q) == [0,4,8]
@test num_facets(q) == 4
@test num_edges(q) == 4

end # module
