module FieldArraysTests

using Test
using InplaceArrays.Arrays
using InplaceArrays.Fields
using InplaceArrays.Fields: MockField, MockBasis
using InplaceArrays.Fields: Valued
using FillArrays
using TensorValues # TODO

np = 4
p = Point(1,2)
x = fill(p,np)

v = 3.0
d = 2
f = MockField{d}(v)
fx = fill(v,np)
∇fx = fill(VectorValue(v,0.0),np)

l = 10
af = Fill(f,l)
ax = fill(x,l)
afx = fill(fx,l)
a∇fx = fill(∇fx,l)
test_array_of_fields(af,ax,afx,grad=a∇fx)

ag = apply_to_field(bcast(+),af,af)
gx = fill(v+v,np)
∇gx = fill(VectorValue(v+v,0.0),np)
agx = fill(gx,l)
a∇gx = fill(∇gx,l)
test_array_of_fields(ag,ax,agx,grad=a∇gx)

w = 2.0
aw = fill(w,l)
ag = apply_to_field(bcast(+),af,aw)
gx = fill(v+w,np)
∇gx = fill(VectorValue(v,0.0),np)
agx = fill(gx,l)
a∇gx = fill(∇gx,l)
test_array_of_fields(ag,ax,agx,grad=a∇gx)

l = 10
af = Fill(f,l)
ax = Fill(x,l)
ag = apply_to_field(bcast(+),af,af)
r1 = evaluate(ag,ax)
@test isa(r1,Fill)

np = 4
p = Point(1,2)
x = fill(p,np)
v = 2.0
d = 2
ndof = 8
wi = 3.0
w = fill(wi,ndof)
r = fill(v+wi,np,ndof)
f = MockBasis{d}(v,ndof)
∇fx = evaluate(∇(f),x)
af = Fill(f,l)
ax = fill(x,l)
aw = fill(w,l)
ag = apply_to_field(bcast(+),af,aw)
agx = fill(r,l)
a∇gx = fill(∇fx,l)
test_array_of_fields(ag,ax,agx,grad=a∇gx)

v = 2.0
d = 2
wi = 3.0
w = fill(wi,ndof)
r = fill(v+wi,np,ndof)
f = MockField{d}(v)
∇r = fill(VectorValue(v,0.0),np,ndof)
af = Fill(f,l)
ax = fill(x,l)
aw = fill(w,l)
ag = apply_to_field(bcast(+),af,aw)
agx = fill(r,l)
a∇gx = fill(∇r,l)
test_array_of_fields(ag,ax,agx,grad=a∇gx)

end # module
