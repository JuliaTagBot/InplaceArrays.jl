"""
    const Point{D,T} = VectorValue{D,T}

Type representing a point of D dimensions with coordinates of type T.
Fields are evaluated at vectors of `Point` objects.
"""
const Point{D,T} = VectorValue{D,T}

"""
    abstract type Field <: Kernel

Abstract type representing physical fields, bases of fields, and other related objects. 
These different cases are distinguished by the return value obtained when evaluating them. E.g.,
a physical field returns a vector of values when evaluated at a vector of points, and a basis of `nf` fields
returns a 2d matrix (`np` x `nf`) when evaluated at a vector of `np` points.

The following functions need to be overloaded:

- [`evaluate_field!(cache,f,x)`](@ref)
- [`field_cache(f,x)`](@ref)

The following functions can be also provided optionally

- [`field_gradient(f)`](@ref)
- [`field_return_type(f,x)`](@ref)

The interface can be tested with

- [`test_field`](@ref)

Most of the functionality implemented in terms of this interface relies in duck typing (this is why all functions in the interface
have the word "field").  Thus, it is not strictly needed to work with types
that inherit from `Field`. This is specially useful in order to accommodate
existing types into this framework without the need to implement a wrapper type that inherits from `Field`.
For instance, a default implementation is available for numbers, which behave like "constant" fields, or arrays of numbers, which behave like
"constant" bases of fields.  However, we recommend that new types inherit from `Field`.

"""
abstract type Field <: Kernel end

"""
$(SIGNATURES)

Returns the cache object needed to evaluate field `f` at the vector of points `x`.
"""
function field_cache(f,x)
  @abstractmethod
end

"""
$(SIGNATURES)

Returns an array containing the values of evaluating the field `f` at the vector of points
`x` by (possibly) using the scratch data in the `cache` object.  The returned value is 
an array,  for which the length of the first axis is `length(x)`, i.e., the number of points where the field has
been evaluated.E.g.,
a physical field returns a vector of `np` values when evaluated at a vector of `np` points, and a basis of `nf` fields
returns a 2d matrix (`np` x `nf`) when evaluated at a vector of `np` points.

This choice is made

- for performance reasons when integrating fields (i.e., adding contributions at different points) since the added values are closer in memory with this layout.
- In order to simplify operations between field objects. E.g., the result of evaluating a physical field and a basis of `nf`fields at a vector of `np` points (which leads to a vector and a matrix of size `(np,)` and `(np,nf)` respectively)  can be conveniently added with the broadcasted sum `.+` operator.


The `cache` object is computed
with the [`field_cache`](@ref) function.

"""
function evaluate_field!(cache,f,x)
  @abstractmethod
end

"""
$(SIGNATURES)

Returns another field that represents the gradient of the given one
"""
function field_gradient(f)
  @abstractmethod
end

# Default return type

"""
$(SIGNATURES)

Computes the type obtained when evaluating field `f` at point `x`.
It returns `typeof(evaluate_field(f,x))` by default.
"""
function field_return_type(f,x)
  typeof(evaluate_field(f,x))
end

# Implement kernel interface

function kernel_return_type(f::Field,x)
  field_return_type(f,x)
end

function kernel_cache(f::Field,x)
  field_cache(f,x)
end

@inline function apply_kernel!(cache,f::Field,x)
  evaluate_field!(cache,f,x)
end

# Testers

"""
    test_field(
      f,
      x::AbstractVector{<:Point},
      v::AbstractArray,cmp=(==);
      grad=nothing)

Function used to test the field interface. `v` is an array containing the expected
result of evaluating the field `f` at the vector of points `x`. The comparison is performed using 
the `cmp` function. For fields objects that support the `field_gradient` function, the key-word
argument `grad` can be used. It should contain the result of evaluating `field_gradient(f)` at x.
The checks are performed with the `@test` macro.
"""
function test_field(
  f,
  x::AbstractVector{<:Point},
  v::AbstractArray,cmp=(==);
  grad=nothing)

  w = evaluate_field(f,x)

  np, = size(w)
  @test length(x) == np
  @test cmp(w,v)
  @test typeof(w) == field_return_type(f,x)

  cf = field_cache(f,x)
  r = evaluate_field!(cf,f,x)
  @test cmp(r,v)

  _x = vcat(x,x)
  _v = vcat(v,v)
  _w = evaluate_field!(cf,f,_x)
  @test cmp(_w,_v)

  if isa(f,Field)
    test_kernel(f,(x,),v,cmp)
  end

  if grad != nothing
    g = field_gradient(f)
    test_field(g,x,grad,cmp)
  end

end

# Some API

"""
    evaluate(f::Field,x)

Equivalent to 

    evaluate_field(f,x)

But only for types that inherit from `Field`. Types that implement
the field interface but not inherit from `Field` (e.g., numbers and arrays of numbers)
cannot use this function. Use `evaluate_field` instead.
"""
function evaluate(f::Field,x)
  evaluate_field(f,x)
end

"""
    evaluate!(cache,f::Field,x)

Equivalent to 

    evaluate_field!(cache,f,x)

But only for types that inherit from `Field`. Types that implement
the field interface but not inherit from `Field` (e.g., numbers and arrays of numbers)
cannot use this function. Use `evaluate_field!` instead.
"""
@inline function evaluate!(cache,f::Field,x)
  evaluate_field!(cache,f,x)
end

"""
$(SIGNATURES)

Evaluates the field `f` at the vector of points `x` by creating a temporary cache internally.
Equivalent to 

    c = field_cache(f,x)
    evaluate_field!(c,f,x)
"""
function evaluate_field(f,x)
  c = field_cache(f,x)
  evaluate_field!(c,f,x)
end

function gradient end

"""
    const ∇ = gradient

Alias for the `gradient` function.
"""
const ∇ = gradient

"""
    gradient(f::Field)

Equivalent to

    field_gradient(f)

But only for types that inherit from `Field`. Types that implement
the field interface but not inherit from `Field` (e.g., numbers and arrays of numbers)
cannot use this function. Use `field_gradient` instead.
"""
function gradient(f::Field)
  field_gradient(f)
end


"""
    field_return_types(f::Tuple,x) -> Tuple

Computes a tuple with the return types of the fields in the tuple `f` when evaluated at the vector
of points `x`

Equivalent to

    tuple(( field_return_type(fi,x) for fi in f)...)
"""
function field_return_types(f::Tuple,x)
  _field_return_types(x,f...)
end

function _field_return_types(x,a,b...)
  Ta = field_return_type(a,x)
  Tb = field_return_types(b,x)
  (Ta,Tb...)
end

function _field_return_types(x,a)
  Ta = field_return_type(a,x)
  (Ta,)
end

"""
    field_caches(f::Tuple,x) -> Tuple

Equivalent to

    tuple((field_cache(fi,x) for fi in f)...)
"""
function field_caches(f::Tuple,x)
  _field_caches(x,f...)
end

function _field_caches(x,a,b...)
  ca = field_cache(a,x)
  cb = field_caches(b,x)
  (ca,cb...)
end

function _field_caches(x,a)
  ca = field_cache(a,x)
  (ca,)
end

"""
    evaluate_fields(f::Tuple,x) -> Tuple

Equivalent to

    tuple((evaluate_fields(fi,x) for fi in f)...)
"""
function evaluate_fields(f::Tuple,x)
  cf = field_caches(f,x)
  evaluate_fields!(cf,f,x)
end

"""
    evaluate_fields!(cf::Tuple,f::Tuple,x) -> Tuple

Equivalent to

    tuple((evaluate_fields!(ci,fi,x) for (ci,fi) in zip(c,f))...)
"""
@inline function evaluate_fields!(cf::Tuple,f::Tuple,x)
  _evaluate_fields!(cf,x,f...)
end

function _evaluate_fields!(c,x,a,b...)
  ca, cb = _split(c...)
  ax = evaluate_field!(ca,a,x)
  bx = evaluate_fields!(cb,b,x)
  (ax,bx...)
end

function _evaluate_fields!(c,x,a)
  ca, = c
  ax = evaluate_field!(ca,a,x)
  (ax,)
end

@inline function _split(a,b...)
  (a,b)
end

"""
    field_gradients(b...) -> Tuple

Equivalent to

    map(field_gradient,b)
"""
@inline function field_gradients(a,b...)
  ga = field_gradient(a)
  gb = field_gradients(b...)
  (ga,gb...)
end

@inline function field_gradients(a)
  ga = field_gradient(a)
  (ga,)
end

"""
    evaluate_all(f::Tuple,x) -> Tuple

Equivalent to

    tuple((evaluate(fi,x) for fi in f)...)
"""
function evaluate_all(f::Tuple,x)
  _evaluate_all(x,f...)
end

function _evaluate_all(x,a,b...)
  ax = evaluate(a,x)
  bx = evaluate_all(b,x)
  (ax, bx...)
end

function _evaluate_all(x,a)
  ax = evaluate(a,x)
  (ax,)
end

"""
    gradient_all(b...) -> Tuple

Equivalent to

    map(gradient,b)
"""
function gradient_all(a,b...)
  ga = gradient(a)
  gb = gradient_all(b...)
  (ga,gb...)
end

function gradient_all(a)
  ga = gradient(a)
  (ga,)
end
