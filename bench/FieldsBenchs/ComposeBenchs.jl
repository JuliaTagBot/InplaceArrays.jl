module ComposeBenchs

using InplaceArrays.Arrays
using InplaceArrays.Fields
import InplaceArrays.Fields: ∇
using InplaceArrays.Fields: MockField, MockBasis
using TensorValues 
using FillArrays

@inline function repeat(n,f,args...)
  for i in 1:n
    f(args...)
  end
  nothing
end

@inline function loop(a,cache)
  for i in eachindex(a)
    ai = getindex!(cache,a,i)
  end
end

@noinline function loop_and_evaluate(ca,cai,cx,a,x)
  for i in eachindex(a)
    ai = getindex!(ca,a,i)
    xi = getindex!(cx,x,i)
    vi = evaluate!(cai,ai,xi)
  end
end

fun2(x,y) = 2*x
∇fun2(x,y) = VectorValue(2*one(x[1]),2*one(x[1]))
∇(::typeof(fun2)) = ∇fun2

function bench1(n)
  v = 3.0
  d = 2
  ndof = 8
  f = MockField{d}(v)
  b = MockBasis{d}(v,ndof)
  g = compose(fun2,f,v)
  np = 4
  p = Point(1,2)
  x = fill(p,np)
  cg = field_cache(g,x)
  @time repeat(n,evaluate!,cg,g,x)
  h = compose(fun2,f,f)
  ch = field_cache(h,x)
  @time repeat(n,evaluate!,ch,h,x)
  j = compose(fun2,b,f)
  cj = field_cache(j,x)
  @time repeat(n,evaluate!,cj,j,x)
end

function bench2(n)
  v = 3.0
  d = 2
  ndof = 8
  f = MockField{d}(v)
  b = MockBasis{d}(v,ndof)
  _g = compose(fun2,f,v)
  g = gradient(_g)
  np = 4
  p = Point(1,2)
  x = fill(p,np)
  cg = field_cache(g,x)
  @time repeat(n,evaluate!,cg,g,x)
  _h = compose(fun2,f,f)
  h = gradient(_h)
  ch = field_cache(h,x)
  @time repeat(n,evaluate!,ch,h,x)
  _j = compose(fun2,b,f)
  j = gradient(_j)
  cj = field_cache(j,x)
  @time repeat(n,evaluate!,cj,j,x)
end

function bench3(n)
  v = 3.0
  d = 2
  ndof = 8
  np = 4
  p = Point(1,2)
  x = fill(p,np)
  f = MockField{d}(v)
  b = MockBasis{d}(v,ndof)
  af = fill(f,n)
  ab = Fill(f,n)
  av = Fill(v,n)
  ax = fill(x,n)
  ag = compose(fun2,af,av)
  cag, cgi, cax = field_cache(ag,ax)
  @time loop_and_evaluate(cag,cgi,cax,ag,ax)
  ah = compose(fun2,af,ab)
  cah, chi, _ = field_cache(ah,ax)
  @time loop_and_evaluate(cah,chi,cax,ah,ax)
  aj = compose(fun2,av,ab)
  caj, cji, _ = field_cache(aj,ax)
  @time loop_and_evaluate(caj,cji,cax,aj,ax)
end

function bench4(n)
  v = 3.0
  d = 2
  ndof = 8
  np = 4
  p = Point(1,2)
  x = fill(p,np)
  f = MockField{d}(v)
  b = MockBasis{d}(v,ndof)
  af = fill(f,n)
  ab = Fill(f,n)
  av = Fill(v,n)
  ax = fill(x,n)
  _ag = compose(fun2,af,av)
  ag = gradient(_ag)
  cag, cgi, cax = field_cache(ag,ax)
  @time loop_and_evaluate(cag,cgi,cax,ag,ax)
  _ah = compose(fun2,af,ab)
  ah = gradient(_ah)
  cah, chi, _ = field_cache(ah,ax)
  @time loop_and_evaluate(cah,chi,cax,ah,ax)
  _aj = compose(fun2,av,ab)
  aj = gradient(_aj)
  caj, cji, _ = field_cache(aj,ax)
  @time loop_and_evaluate(caj,cji,cax,aj,ax)
end

for n in (1,1,10,1000,100000)
  @eval begin
    println("+++ runing suite for n = $($n) +++")
    bench1($n)
    bench2($n)
    bench3($n)
    bench4($n)
  end
end



end # module
