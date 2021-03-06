module ConstantFieldsTests

using InplaceArrays.TensorValues
using InplaceArrays.Arrays
using InplaceArrays.Fields

for v in (3.0,VectorValue(1,2))
  f = v
  xi = Point(2,1)
  np = 4
  x = fill(xi,np)
  fx = fill(v,np)
  ∇fx = fill(zero(v[1]),np)
  test_field(f,x,fx,grad=∇fx)
end

for v in (3.0,VectorValue(1,2))
  f = [v,2*v,3*v]
  xi = Point(2,1)
  np = 4
  x = fill(xi,np)
  fx = repeat(f',np)
  ∇fx = fill(zero(v[1]),size(fx)...)
  test_field(f,x,fx,grad=∇fx)
end

end # module
