"""

The exported names are
$(EXPORTS)
"""
module ReferenceFEs

using Test
using DocStringExtensions
using LinearAlgebra
using Combinatorics

using InplaceArrays.Helpers
using InplaceArrays.TensorValues
using InplaceArrays.Arrays
using InplaceArrays.Fields
using InplaceArrays.Polynomials

import InplaceArrays.Arrays: kernel_cache
import InplaceArrays.Arrays: apply_kernel!
import InplaceArrays.Arrays: kernel_return_type
import InplaceArrays.Fields: evaluate
import InplaceArrays.Polynomials: MonomialBasis

import Base: ==

export Polytope
export ExtrusionPolytope
export get_faces
export get_dimrange
export get_vertex_coordinates
export get_facet_normals
export get_facet_orientations
export get_edge_tangents
export get_vertex_permutations
export get_vtkid
export get_vtknodes
export num_dims
export num_vertices
export num_faces
export num_facets
export num_edges
export get_facedims
export get_offsets
export get_offset
export test_polytope
export VERTEX
export SEGMENT
export TRI
export QUAD
export TET
export HEX
export WEDGE
export PYRAMID
export HEX_AXIS
export TET_AXIS
export INVALID_PERM

export Dof
export evaluate_dof!
export evaluate_dof
export dof_cache
export dof_return_type
export test_dof
export evaluate_dof_array

export ReferenceFE
export GenericRefFE
export get_polytope
export get_prebasis
export get_dofs
export get_face_own_dofids
export get_own_dofs_permutations
export get_shapefuns
export compute_shapefuns
export test_reference_fe
export num_dofs

export LagrangianRefFE
export LagrangianDofBasis
export compute_monomial_basis
export compute_own_nodes
export compute_face_orders
export compute_nodes
export compute_own_nodes_permutations
export compute_lagrangian_reffaces
export get_node_coordinates
export get_dof_to_node
export get_dof_to_comp
export get_node_and_comp_to_dof

export SerendipityRefFE

include("Polytopes.jl")

include("ExtrusionPolytopes.jl")

include("Dofs.jl")

include("MockDofs.jl")

include("LagrangianDofBases.jl")

include("ReferenceFEInterfaces.jl")

include("LagrangianRefFEs.jl")

include("SerendipityRefFEs.jl")

end # module
