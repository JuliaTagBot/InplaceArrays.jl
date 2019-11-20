module ExtrusionPolytopesTests

using Test
using InplaceArrays.Helpers
using InplaceArrays.TensorValues
using InplaceArrays.Arrays
using InplaceArrays.Fields
using InplaceArrays.ReferenceFEs

@test num_faces(VERTEX) == 1
@test num_dims(VERTEX) == 0

p = Polytope(HEX_AXIS, HEX_AXIS)
test_polytope(p,optional=true)

@test get_faces(p,0,0) == [[1], [2], [3], [4]]
@test get_faces(p,1,0) == [[1, 2], [3, 4], [1, 3], [2, 4]]
@test get_faces(p,2,0) == [[1, 2, 3, 4]]
@test get_faces(p,0,1) == [[1, 3], [1, 4], [2, 3], [2, 4]]
@test get_faces(p,1,1) == [[1], [2], [3], [4]]
@test get_faces(p,2,1) == [[1, 2, 3, 4]]
@test get_faces(p,0,2) == [[1], [1], [1], [1]]
@test get_faces(p,1,2) == [[1], [1], [1], [1]]
@test get_faces(p,2,2) == [[1]]
@test get_facedims(p) == [0,0,0,0,1,1,1,1,2]
@test get_offsets(p) == [0,4,8]
@test num_facets(p) == 4
@test num_edges(p) == 4

r = Point{2,Float64}[(1, 0), (1, 0), (0, 1), (0, 1)]
@test edge_tangents(p) == r

r = [
  [1, 2, 3, 4], [1, 3, 2, 4], [2, 1, 4, 3], [2, 4, 1, 3],
  [3, 1, 4, 2], [3, 4, 1, 2], [4, 2, 3, 1], [4, 3, 2, 1]]
@test vertex_permutations(p) == r

r = Point{2,Float64}[(0, -1), (0, 1), (-1, 0), (1, 0)]
@test facet_normals(p) == r

@test num_faces(p) == 9
@test num_dims(p) == 2

p = Polytope(TET_AXIS, TET_AXIS, TET_AXIS)
test_polytope(p,optional=true)

@test num_faces(p) == 15
@test num_dims(p) == 3

x = Point{3,Float64}[(0, 0, 0), (1, 0, 0), (0, 1, 0), (0, 0, 1)]
@test vertex_coordinates(p) == x

p = SEGMENT
test_polytope(p,optional=true)
@test vertex_coordinates(p) == VectorValue{1,Float64}[(0),(1)]
@test edge_tangents(p) == VectorValue{1,Float64}[(1)]
@test facet_normals(p) == VectorValue{1,Float64}[(-1),(1)]

p = VERTEX
test_polytope(p,optional=true)
@test vertex_coordinates(p) == VectorValue{0,Float64}[()]
@test edge_tangents(p) == VectorValue{0,Float64}[]
@test facet_normals(p) == VectorValue{0,Float64}[]

test_polytope(TRI,optional=true)
test_polytope(QUAD,optional=true)
test_polytope(TET,optional=true)
test_polytope(HEX,optional=true)

@test num_facets(SEGMENT) == 2
@test num_facets(TRI) == 3
@test num_facets(QUAD) == 4
@test num_facets(TET) == 4
@test num_facets(HEX) == 6

@test num_vertices(PYRAMID) == 5
# TODO There is a problem with PYRAMID
#@test num_edges(PYRAMID) == 8
#@test num_facets(PYRAMID) == 5

end # module
