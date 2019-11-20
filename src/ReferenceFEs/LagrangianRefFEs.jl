
"""
"""
const INVALID_PERM = 0

"""
    struct LagrangianRefFE{D} <: ReferenceFE{D}
      data::GenericRefFE{D}
      facenodeids::Vector{Vector{Int}}
      nodeperms::Vector{Vector{Int}},
    end

For this type

-  `get_dofs(reffe)` returns a `LagrangianDofBasis`
-  `get_prebasis(reffe)` returns a `MonomialBasis`
-  `ReferenceFE{N}(reffe,faceid) where N` returns a `LagrangianRefFE{N}`
"""
struct LagrangianRefFE{D} <: ReferenceFE{D}
  data::GenericRefFE{D}
  facenodeids::Vector{Vector{Int}}
  nodeperms::Vector{Vector{Int}}
  @doc """
  """
  function LagrangianRefFE(
    polytope::Polytope{D},
    prebasis::MonomialBasis,
    dofs::LagrangianDofBasis,
    facenodeids::Vector{Vector{Int}},
    nodeperms::Vector{Vector{Int}},
    reffaces::Vector{<:LagrangianRefFE}...) where D

    facedofids = _generate_nfacedofs(facenodeids,dofs.node_and_comp_to_dof)
    dofperms = _find_dof_permutaions(nodeperms,dofs.node_and_comp_to_dof,facenodeids,facedofids)

    data = GenericRefFE(
      polytope,prebasis,dofs,facedofids;
      dofperms = dofperms,
      reffaces = reffaces)

    new{D}(data,facenodeids,nodeperms)
  end
end

num_dofs(reffe::LagrangianRefFE) = reffe.data.ndofs

get_polytope(reffe::LagrangianRefFE) = reffe.data.polytope

get_prebasis(reffe::LagrangianRefFE) = reffe.data.prebasis

get_dofs(reffe::LagrangianRefFE) = reffe.data.dofs

get_face_dofids(reffe::LagrangianRefFE) = reffe.data.facedofids

get_dof_permutations(reffe::LagrangianRefFE) = reffe.data.dofperms

get_shapefuns(reffe::LagrangianRefFE) = reffe.data.shapefuns

function ReferenceFE{N}(reffe::LagrangianRefFE,iface::Integer) where N
  ReferenceFE{N}(reffe.data,iface)
end

function ReferenceFE{D}(reffe::LagrangianRefFE{D},iface::Integer) where D
  @assert iface==1 "Only one D-face"
  reffe
end

# Helpers for LagrangianRefFE

function _generate_nfacedofs(nfacenodes,node_and_comp_to_dof)
  faces = 1:length(nfacenodes)
  T = eltype(node_and_comp_to_dof)
  comps = 1:n_components(T)
  nfacedofs = [Int[] for i in faces]
  for face in faces
    nodes = nfacenodes[face]
    # Node major
    for comp in comps
      for node in nodes
        comp_to_dofs = node_and_comp_to_dof[node]
        dof = comp_to_dofs[comp]
        push!(nfacedofs[face],dof)
      end
    end
  end
  nfacedofs
end

function _find_dof_permutaions(node_perms,node_and_comp_to_dof,nfacenodeids,nfacedofsids)
  dof_perms = Vector{Int}[]
  T = eltype(node_and_comp_to_dof)
  ncomps = n_components(T)
  idof_to_dof = nfacedofsids[end]
  inode_to_node = nfacenodeids[end]
  for inode_to_pinode in node_perms
    ninodes = length(inode_to_pinode)
    nidofs = ncomps*ninodes
    idof_to_pidof = fill(INVALID_PERM,nidofs)
    for (inode,ipnode) in enumerate(inode_to_pinode)
      if ipnode == INVALID_PERM
        continue
      end
      node = inode_to_node[inode]
      pnode = inode_to_node[ipnode]
      comp_to_pdof = node_and_comp_to_dof[pnode]
      comp_to_dof = node_and_comp_to_dof[node]
      for comp in 1:ncomps
        dof = comp_to_dof[comp]
        pdof = comp_to_pdof[comp]
        idof = findfirst(i->i==dof,idof_to_dof)
        ipdof = findfirst(i->i==pdof,idof_to_dof)
        idof_to_pidof[idof] = ipdof
      end
    end
    push!(dof_perms,idof_to_pidof)
  end
  dof_perms
end

# Construction of LagrangianRefFE from Polytopes

"""
    LagrangianRefFE(::Type{T},p::Polytope,orders) where T
    LagrangianRefFE(::Type{T},p::Polytope,order::Int) where T
"""
function LagrangianRefFE(::Type{T},p::Polytope{D},orders) where {T,D}
  prebasis = compute_monomial_basis(T,p,orders)
  nodes, facenodeids = compute_nodes(p,orders)
  dofs = LagrangianDofBasis(T,nodes)
  interior_nodes = dofs.nodes[facenodeids[end]]
  nodeperms = compute_node_permutations(p, interior_nodes)
  reffaces = compute_lagrangian_reffaces(T,p,orders)
  LagrangianRefFE(p,prebasis,dofs,facenodeids,nodeperms,reffaces...)
end

"""
"""
function MonomialBasis(::Type{T},p::Polytope,orders) where T
  compute_monomial_basis(T,p,orders)
end

"""
"""
function LagrangianDofBasis(::Type{T},p::Polytope,orders) where T
  nodes, _ = compute_nodes(p,orders)
  LagrangianDofBasis(T,nodes)
end

# Constructors taking Int

function LagrangianRefFE(::Type{T},p::Polytope{D},order::Int) where {T,D}
  orders = tfill(order,Val{D}())
  LagrangianRefFE(T,p,orders)
end

function MonomialBasis(::Type{T},p::Polytope{D},order::Int) where {D,T}
  orders = tfill(order,Val{D}())
  MonomialBasis(T,p,orders)
end

function LagrangianDofBasis(::Type{T},p::Polytope{D},order::Int) where {T,D}
  orders = tfill(order,Val{D}())
  LagrangianDofBasis(T,p,orders)
end

# Queries needed to be implemented for polytopes in order to use them
# for building LagrangianRefFEs in a seamless way

"""
"""
function compute_monomial_basis(::Type{T},p::Polytope,orders) where T
  @abstractmethod
end

"""
"""
function compute_interior_nodes(p::Polytope,orders)
  @abstractmethod
end

"""
"""
function compute_face_orders(p::Polytope,face::Polytope,iface::Int,orders)
  @abstractmethod
end

"""
"""
function compute_nodes(p::Polytope,orders)
  _compute_nodes(p,orders)
end

"""
"""
function compute_node_permutations(p::Polytope, interior_nodes)
  _compute_node_permutations(p, interior_nodes)
end

"""
"""
function compute_lagrangian_reffaces(::Type{T},p::Polytope,orders) where T
  _compute_lagrangian_reffaces(T,p,orders)
end

# Default implementations

function _compute_nodes(p,orders)
  if all(orders .== 1)
    _compute_linear_nodes(p)
  else
    _compute_high_order_nodes(p,orders)
  end
end

function _compute_linear_nodes(p)
  x = vertex_coordinates(p)
  facenodes = [Int[] for i in 1:num_faces(p)]
  for i in 1:num_vertices(p)
    push!(facenodes[i],i)
  end
  x, facenodes
end

function _compute_high_order_nodes(p::Polytope{D},orders) where D
  nodes = Point{D,Float64}[]
  facenodes = [Int[] for i in 1:num_faces(p)]
  _compute_high_order_nodes_dim_0!(nodes,facenodes,p)
  for d in 1:(num_dims(p)-1)
    _compute_high_order_nodes_dim_d!(nodes,facenodes,p,orders,Val{d}())
  end
  _compute_high_order_nodes_dim_D!(nodes,facenodes,p,orders)
  (nodes, facenodes)
end

function _compute_high_order_nodes_dim_0!(nodes,facenodes,p)
  x = vertex_coordinates(p)
  k = 1 
  for vertex in 1:num_vertices(p)
    push!(nodes,x[vertex])
    push!(facenodes[vertex],k)
    k += 1
  end
end

@noinline function _compute_high_order_nodes_dim_d!(nodes,facenodes,p,orders,::Val{d}) where d
  x = vertex_coordinates(p)
  offset = get_offset(p,d)
  k = length(nodes)+1
  for iface in 1:num_faces(p,d)
    face = Polytope{d}(p,iface)
    face_ref_x = vertex_coordinates(face)
    face_prebasis = MonomialBasis(Float64,face,1)
    change = inv(evaluate(face_prebasis,face_ref_x))
    face_shapefuns = change_basis(face_prebasis,change)
    face_vertex_ids = get_faces(p,d,0)[iface]
    face_x = x[face_vertex_ids]
    face_orders = compute_face_orders(p,face,iface,orders)
    face_interior_nodes = compute_interior_nodes(face,face_orders)
    face_high_x = evaluate(face_shapefuns,face_interior_nodes)*face_x
    for xi in 1:length(face_high_x)
      push!(nodes,face_high_x[xi])
      push!(facenodes[iface+offset],k)
      k += 1
    end
  end
end

function _compute_high_order_nodes_dim_D!(nodes,facenodes,p,orders)
  k = length(nodes)+1
  p_high_x = compute_interior_nodes(p,orders)
  for xi in 1:length(p_high_x)
    push!(nodes,p_high_x[xi])
    push!(facenodes[end],k)
    k += 1
  end
end

_compute_node_permutations(::Polytope{0}, interior_nodes) = [[1]]

function _compute_node_permutations(p, interior_nodes)
  vertex_to_coord = vertex_coordinates(p)
  lbasis = MonomialBasis(Float64,p,1)
  change = inv(evaluate(lbasis,vertex_to_coord))
  lshapefuns = change_basis(lbasis,change)
  perms = vertex_permutations(p)
  map = evaluate(lshapefuns,interior_nodes) 
  pvertex_to_coord = similar(vertex_to_coord)
  node_perms = Vector{Int}[]
  tol = 1.0e-10
  for vertex_to_pvertex in perms
    node_to_pnode = fill(INVALID_PERM,length(interior_nodes))
    pvertex_to_coord[vertex_to_pvertex] = vertex_to_coord
    pinterior_nodes = map*pvertex_to_coord
    for node in 1:length(interior_nodes)
      x = interior_nodes[node]
      pnode = findfirst(i->norm(i-x)<tol,pinterior_nodes)
      if pnode != nothing
         node_to_pnode[node] = pnode
      end
    end
    push!(node_perms,node_to_pnode)
  end
  node_perms
end

_compute_lagrangian_reffaces(::Type{T},p::Polytope{0},orders) where T = ()

function _compute_lagrangian_reffaces(::Type{T},p::Polytope{D},orders) where {T,D}
  reffaces = [ LagrangianRefFE{d}[]  for d in 0:D ]
  p0 = Polytope{0}(p,1)
  reffe0 = LagrangianRefFE(T,p0,())
  for vertex in 1:num_vertices(p)
    push!(reffaces[0+1],reffe0)
  end
  offsets = get_offsets(p)
  for d in 1:(num_dims(p)-1)
    offset = offsets[d+1]
    for iface in 1:num_faces(p,d)
      face = Polytope{d}(p,iface)
      face_orders = compute_face_orders(p,face,iface,orders)
      refface = LagrangianRefFE(T,face,face_orders)
      push!(reffaces[d+1],refface)
    end
  end
  tuple(reffaces...)
end

# Particular implementation for ExtrusionPolytope

function compute_monomial_basis(::Type{T},p::ExtrusionPolytope{D},orders) where {D,T}
  extrusion = Tuple(p.extrusion.array)
  terms = _monomial_terms(extrusion,orders)
  MonomialBasis{D}(T,orders,terms)
end

function compute_interior_nodes(p::ExtrusionPolytope{D},orders) where D
  extrusion = Tuple(p.extrusion.array)
  _interior_nodes(extrusion,orders)
end

function compute_face_orders(p::ExtrusionPolytope,face::ExtrusionPolytope{D},iface::Int,orders) where D
  d = num_dims(face)
  offset = get_offset(p,d)
  nface = p.nfaces[iface+offset]
  face_orders = _extract_nonzeros(nface.extrusion,orders)
  face_orders
end

function compute_nodes(p::ExtrusionPolytope{D},orders) where D
  _nodes, facenodes = _compute_nodes(p,orders)
  terms = _coords_to_terms(_nodes,orders)
  nodes = _terms_to_coords(terms,orders)
  (nodes, facenodes)
end

# Helpers for the ExtrusionPolytope-related implementation

function _monomial_terms(extrusion::NTuple{D,Int},orders) where D
  terms = CartesianIndex{D}[]
  if D == 0
    push!(terms,CartesianIndex(()))
    return terms
  end
  _check_orders(extrusion,orders)
  M = mutable(VectorValue{D,Int})
  term = zero(M)
  _orders = M(orders)
  k = 0
  _add_terms!(terms,term,extrusion,_orders,D,k)
  terms
end

function _interior_nodes(extrusion::NTuple{D,Int},orders) where D
  _check_orders(extrusion,orders)
  terms = CartesianIndex{D}[]
  M = mutable(VectorValue{D,Int})
  term = zero(M)
  _orders = M(orders)
  k = 1
  _add_terms!(terms,term,extrusion,_orders,D,k)
  _terms_to_coords(terms,orders)
end

function _check_orders(extrusion,orders)
  D = length(extrusion)
  @assert length(orders) == D "container of orders not long enough"
  _orders = collect(orders)
  if extrusion[D] == HEX_AXIS
    _orders[D] = 0
  end
  for d in (D-1):-1:1
    if (extrusion[d] == HEX_AXIS || d == 1) && _orders[d+1] == 0
      _orders[d] = 0
    end
  end
  nz = _orders[_orders .!= 0]
  if length(nz) > 1
    @assert all(nz .== nz[1]) "The provided anisotropic order is not compatible with polytope topology"
  end
  nothing
end

function _add_terms!(terms,term,extrusion,orders,dim,k)
  _term = copy(term)
  _orders = copy(orders)
  indexbase = 1
  for i in k:(_orders[dim]-k)
    _term[dim] = i + indexbase
    if dim > 1
      if (extrusion[dim] == TET_AXIS) && i != 0
        _orders .-= 1
      end
      _add_terms!(terms,_term,extrusion,_orders,dim-1,k)
    else
      push!(terms,CartesianIndex(Tuple(_term)))
    end
  end
end

function _coords_to_terms(coords::Vector{<:Point{D}},orders) where D
  indexbase = 1
  terms = CartesianIndex{D}[]
  P = Point{D,Int}
  t = zero(mutable(P))
  for x in coords
    for d in 1:D
      t[d] = round(x[d]*orders[d]) + indexbase
    end
    term = CartesianIndex(Tuple(t))
    push!(terms,term)
  end
  terms
end

function  _terms_to_coords(terms::Vector{CartesianIndex{D}},orders) where D
  P = Point{D,Float64}
  indexbase = 1
  nodes = P[]
  x = zero(mutable(P))
  for t in terms
    for d in 1:D
      x[d] = (t[d] - indexbase) / orders[d]
    end
    node = P(x)
    push!(nodes,node)
  end
  nodes
end

function _extract_nonzeros(mask,values)
  b = Int[]
  for (m,n) in zip(mask,values)
    if (m != 0)
      push!(b, n)
    end
  end
  return Tuple(b)
end

