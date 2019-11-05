```@meta
CurrentModule = InplaceArrays.Fields
```
# Gridap.Fields

```@docs
Fields
```

## Interface

```@docs
Field
Point
evaluate_field!(cache,f,x)
field_cache(f,x)
field_gradient(f)
field_return_type(f,x)
evaluate_gradient!(cache,f,x)
gradient_cache(f,x)
test_field
```
## Helper functions using fields

```@docs
evaluate_field(f,x)
evaluate(f::Field,x)
evaluate!(cache,f::Field,x)
gradient(f::Field)
∇
gradient_type
```

## Working with several fields at once

```@docs
field_return_types(f::Tuple,x)
field_caches(f::Tuple,x)
evaluate_fields(f::Tuple,x)
evaluate_fields!(cf::Tuple,f::Tuple,x)
field_gradients(a,b...)
gradient_all(a,b...)
evaluate_all(f::Tuple,x)
```

## Applying kernels to fields

```@docs
apply_kernel_to_field(k,f...)
apply_kernel_gradient(k,f...)
```

## Working with arrays of fields

```@docs
evaluate_field_array(a::AbstractArray,x::AbstractArray)
evaluate(::AbstractArray{<:Field},::AbstractArray)
field_array_gradient(a::AbstractArray)
gradient(::AbstractArray{<:Field})
field_array_cache(a::AbstractArray,x::AbstractArray)
test_array_of_fields
```

## Working with several arrays of fields at once

```@docs
evaluate_field_arrays(f::Tuple,x::AbstractArray)
field_array_gradients(f...)
```
## Applying kernels to arrays of fields

```@docs
apply_to_field_array(k,f::AbstractArray...)
kernel_evaluate(k,x,f...)
apply_gradient(k,f...)
```

## Operations on fields and arrays of fields


```@docs
compose(g::Function,f...)
compose(g::Function,f::AbstractArray...)
lincomb(a::Field,b::AbstractVector)
lincomb(a::AbstractArray,b::AbstractArray)
varinner(a,b)
varinner(a::AbstractArray,b::AbstractArray)
attachmap(f,phi)
attachmap(f::AbstractArray,phi::AbstractArray)
integrate(f,x,w,j)
integrate(f::AbstractArray,x,w,j)
```


