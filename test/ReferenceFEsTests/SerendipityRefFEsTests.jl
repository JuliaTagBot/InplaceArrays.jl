module SerendipityRefFEsTests

using Test
using InplaceArrays.Fields
using InplaceArrays.ReferenceFEs

reffe = SerendipityRefFE(Float64,QUAD,2)
@test reffe.data.dofs.nodes == Point{2,Float64}[
  (0.0, 0.0), (1.0, 0.0), (0.0, 1.0), (1.0, 1.0),
  (0.5, 0.0), (0.5, 1.0), (0.0, 0.5), (1.0, 0.5)]
@test reffe.facenodeids == [[1], [2], [3], [4], [5], [6], [7], [8], Int[]]

reffe = SerendipityRefFE(Float64,QUAD,4)
@test reffe.facenodeids == [[1], [2], [3], [4], [5, 6, 7], [8, 9, 10], [11, 12, 13], [14, 15, 16], [17]] 

reffe = SerendipityRefFE(Float64,HEX,2)
@test reffe.facenodeids == [
  [1], [2], [3], [4], [5], [6], [7], [8],
  [9], [10], [11], [12], [13], [14], [15], [16],
  [17], [18], [19], [20], Int[], Int[], Int[], Int[], Int[], Int[], Int[]]

end # module
