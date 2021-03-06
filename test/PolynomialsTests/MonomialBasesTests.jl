module MonomialBasisTests

using Test
using InplaceArrays.TensorValues
using InplaceArrays.Fields
using InplaceArrays.Polynomials

xi = Point(2,3)
np = 5
x = fill(xi,np)

# order 0 degenerated case

order = 0
V = Float64
G = gradient_type(V,xi)
H = gradient_type(G,xi)
b = MonomialBasis{2}(V,order)

v = V[1.0,]
g = G[(0.0, 0.0),]
h = H[(0.0, 0.0, 0.0, 0.0),]

bx = repeat(permutedims(v),np)
∇bx = repeat(permutedims(g),np)
Hbx = repeat(permutedims(h),np)
test_field(b,x,bx,grad=∇bx,hessian=Hbx)

# Real-valued Q space with isotropic order

order = 1
V = Float64
G = gradient_type(V,xi)
H = gradient_type(G,xi)
b = MonomialBasis{2}(V,order)

v = V[1.0, 2.0, 3.0, 6.0]
g = G[(0.0, 0.0), (1.0, 0.0), (0.0, 1.0), (3.0, 2.0)]
h = H[(0.0, 0.0, 0.0, 0.0), (0.0, 0.0, 0.0, 0.0), (0.0, 0.0, 0.0, 0.0), (0.0, 1.0, 1.0, 0.0)]

bx = repeat(permutedims(v),np)
∇bx = repeat(permutedims(g),np)
Hbx = repeat(permutedims(h),np)
test_field(b,x,bx,grad=∇bx,hessian=Hbx)

# Real-valued Q space with an isotropic order

orders = (1,2)
V = Float64
G = gradient_type(V,xi)
b = MonomialBasis{2}(V,orders)

v = V[1.0, 2.0, 3.0, 6.0, 9.0, 18.0]
g = G[(0.0, 0.0), (1.0, 0.0), (0.0, 1.0), (3.0, 2.0), (0.0, 6.0), (9.0, 12.0)]

bx = repeat(permutedims(v),np)
∇bx = repeat(permutedims(g),np)
test_field(b,x,bx,grad=∇bx)

# Vector-valued Q space with isotropic order

order = 1
V = VectorValue{3,Float64}
G = gradient_type(V,xi)
H = gradient_type(G,xi)
b = MonomialBasis{2}(V,order)

v = V[[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0],
      [2.0, 0.0, 0.0], [0.0, 2.0, 0.0], [0.0, 0.0, 2.0],
      [3.0, 0.0, 0.0], [0.0, 3.0, 0.0], [0.0, 0.0, 3.0],
      [6.0, 0.0, 0.0], [0.0, 6.0, 0.0], [0.0, 0.0, 6.0]]

g = G[[0.0 0.0 0.0; 0.0 0.0 0.0], [0.0 0.0 0.0; 0.0 0.0 0.0],
      [0.0 0.0 0.0; 0.0 0.0 0.0], [1.0 0.0 0.0; 0.0 0.0 0.0],
      [0.0 1.0 0.0; 0.0 0.0 0.0], [0.0 0.0 1.0; 0.0 0.0 0.0],
      [0.0 0.0 0.0; 1.0 0.0 0.0], [0.0 0.0 0.0; 0.0 1.0 0.0],
      [0.0 0.0 0.0; 0.0 0.0 1.0], [3.0 0.0 0.0; 2.0 0.0 0.0],
      [0.0 3.0 0.0; 0.0 2.0 0.0], [0.0 0.0 3.0; 0.0 0.0 2.0]]

h = H[
      (0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0),
      (0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0),
      (0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0),
      (0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0),
      (0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0),
      (0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0),
      (0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0),
      (0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0),
      (0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0),
      (0.0,1.0,1.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0),
      (0.0,0.0,0.0,0.0,0.0,1.0,1.0,0.0,0.0,0.0,0.0,0.0),
      (0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,1.0,1.0,0.0)]

bx = repeat(permutedims(v),np)
∇bx = repeat(permutedims(g),np)
Hbx = repeat(permutedims(h),np)
test_field(b,x,bx,grad=∇bx,hessian=Hbx)

# Vector-valued Q space with an-isotropic order

orders = (1,2)
V = VectorValue{2,Float64}
G = gradient_type(V,xi)
b = MonomialBasis{2}(V,orders)

v = V[
 (1.0, 0.0), (0.0, 1.0), (2.0, 0.0), (0.0, 2.0),
 (3.0, 0.0), (0.0, 3.0), (6.0, 0.0), (0.0, 6.0),
 (9.0, 0.0), (0.0, 9.0), (18.0, 0.0), (0.0, 18.0)]

g = G[
  (0.0, 0.0, 0.0, 0.0), (0.0, 0.0, 0.0, 0.0),
  (1.0, 0.0, 0.0, 0.0), (0.0, 0.0, 1.0, 0.0),
  (0.0, 1.0, 0.0, 0.0), (0.0, 0.0, 0.0, 1.0),
  (3.0, 2.0, 0.0, 0.0), (0.0, 0.0, 3.0, 2.0),
  (0.0, 6.0, 0.0, 0.0), (0.0, 0.0, 0.0, 6.0),
  (9.0, 12.0, 0.0, 0.0), (0.0, 0.0, 9.0, 12.0)]

bx = repeat(permutedims(v),np)
∇bx = repeat(permutedims(g),np)
test_field(b,x,bx,grad=∇bx)

# Real-valued P space

order = 1
V = Float64
G = gradient_type(V,xi)
filter = (e,o) -> sum(e) <= o
b = MonomialBasis{2}(V,order,filter)

v = V[1.0, 2.0, 3.0]
g = G[[0.0, 0.0], [1.0, 0.0], [0.0, 1.0]]

bx = repeat(permutedims(v),np)
∇bx = repeat(permutedims(g),np)
test_field(b,x,bx,grad=∇bx)

# Vector-valued P space

order = 1
V = VectorValue{3,Float64}
G = gradient_type(V,xi)
filter = (e,o) -> sum(e) <= o
b = MonomialBasis{2}(V,order,filter)

v = V[[1.0; 0.0; 0.0], [0.0; 1.0; 0.0], [0.0; 0.0; 1.0],
      [2.0; 0.0; 0.0], [0.0; 2.0; 0.0], [0.0; 0.0; 2.0],
      [3.0; 0.0; 0.0], [0.0; 3.0; 0.0], [0.0; 0.0; 3.0]]

g = G[[0.0 0.0 0.0; 0.0 0.0 0.0], [0.0 0.0 0.0; 0.0 0.0 0.0],
      [0.0 0.0 0.0; 0.0 0.0 0.0], [1.0 0.0 0.0; 0.0 0.0 0.0],
      [0.0 1.0 0.0; 0.0 0.0 0.0], [0.0 0.0 1.0; 0.0 0.0 0.0],
      [0.0 0.0 0.0; 1.0 0.0 0.0], [0.0 0.0 0.0; 0.0 1.0 0.0],
      [0.0 0.0 0.0; 0.0 0.0 1.0]]

bx = repeat(permutedims(v),np)
∇bx = repeat(permutedims(g),np)
test_field(b,x,bx,grad=∇bx)

order = 1
b = MonomialBasis{1}(Float64,order)
@test evaluate(b,Point{1,Float64}[(0,),(1,)]) == [1.0 0.0; 1.0 1.0]

b = MonomialBasis{0}(VectorValue{2,Float64},order)
@test evaluate(b,Point{0,Float64}[(),()]) == VectorValue{2,Float64}[(1.0, 0.0) (0.0, 1.0); (1.0, 0.0) (0.0, 1.0)] 

end # module
