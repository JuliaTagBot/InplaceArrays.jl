module ArraysBenchs

using InplaceArrays
using FillArrays

@inline function loop(a,cache)
  for i in eachindex(a)
    ai = getindex!(cache,a,i)
  end
end

@inline function loop_and_evaluate(ca,cai,cx,a,x...)
  for i in eachindex(a)
    ai = getindex!(ca,a,i)
    xi = getitems!(cx,x,i...)
    vi = evaluate_functor!(cai,ai,xi...)
  end
end

function bench1(n)
  a = rand(n)
  c = evaluate_functor_with_arrays(-,a)
  cache = array_cache(c)
  @time loop(c,cache)
end

function bench2(n)
  a = rand(n)
  b = rand(n)
  c = evaluate_functor_with_arrays(-,a,b)
  cache = array_cache(c)
  @time loop(c,cache)
end

function bench3(n)
  a = fill(rand(2,3),n)
  b = rand(n)
  c = evaluate_functor_with_arrays(bcast(-),a,b)
  cache = array_cache(c)
  @time loop(c,cache)
end

function bench4(n)
  a = fill(rand(2,3),n)
  b = rand(n)
  c = evaluate_functor_with_arrays(bcast(-),a,b)
  d = evaluate_functor_with_arrays(bcast(+),a,c)
  e = evaluate_functor_with_arrays(bcast(*),d,c)
  cache = array_cache(e)
  @time loop(e,cache)
end

function bench5(n)
  a = fill(+,n)
  b = fill(-,n)
  c = compose_functor_with_arrays(*,a,b)
  cache = array_cache(c)
  @time loop(c,cache)
end

function bench5b(n)
  a = fill(+,n)
  b = fill(-,n)
  c = compose_functor_with_arrays(*,a,b)
  x = rand(n)
  y = rand(n)
  cc, cci, cx = array_of_functors_cache(c,x,y)
  @time loop_and_evaluate(cc,cci,cx,c,x,y)
end

function bench5c(n)
  a = fill(+,n)
  b = fill(-,n)
  c = compose_functor_with_arrays(*,a,b)
  x = rand(n)
  y = rand(n)
  v = evaluate_array_of_functors(c,x,y)
  cache = array_cache(v)
  @time loop(v,cache)
end

function bench6(n)
  a = fill(bcast(+),n)
  b = fill(bcast(-),n)
  c = compose_functor_with_arrays(bcast(*),a,b)
  cache = array_cache(c)
  @time loop(c,cache)
end

function bench6b(n)
  a = fill(bcast(+),n)
  b = fill(bcast(-),n)
  c = compose_functor_with_arrays(bcast(*),a,b)
  x = [rand(mod(i-1,3)+1,3) for i in 1:n]
  y = [rand(1,3) for i in 1:n]
  cc, cci, cx = array_of_functors_cache(c,x,y)
  @time loop_and_evaluate(cc,cci,cx,c,x,y)
end

function bench6c(n)
  a = fill(bcast(+),n)
  b = fill(bcast(-),n)
  c = compose_functor_with_arrays(bcast(*),a,b)
  x = [rand(mod(i-1,3)+1,3) for i in 1:n]
  y = [rand(1,3) for i in 1:n]
  v = evaluate_array_of_functors(c,x,y)
  cache = array_cache(v)
  @time loop(v,cache)
end

function bench7(n)
  a = fill(+,n)
  x = rand(n)
  y = rand(n)
  v = evaluate_array_of_functors(a,x,y)
  cache = array_cache(v)
  @time loop(v,cache)
end

function bench8(n)
  a = fill(bcast(+),n)
  x = [rand(2,3) for i in 1:n]
  y = [rand(1,3) for i in 1:n]
  v = evaluate_array_of_functors(a,x,y)
  cache = array_cache(v)
  @time loop(v,cache)
end

function bench9(n)
  a = Fill(bcast(+),n)
  x = [rand(mod(i-1,3)+1,3) for i in 1:n]
  y = [rand(1,3) for i in 1:n]
  v = evaluate_array_of_functors(a,x,y)
  cache = array_cache(v)
  @time loop(v,cache)
end

for n in (1,1,10,1000,100000)
  @eval begin
    println("+++ runing suite for n = $($n) +++")
    bench1($n)
    bench2($n)
    bench3($n)
    bench4($n)
    bench5($n)
    bench5b($n)
    bench5c($n)
    bench6($n)
    bench6b($n)
    bench6c($n)
    bench7($n)
    bench8($n)
    bench9($n)
  end
end

end # module