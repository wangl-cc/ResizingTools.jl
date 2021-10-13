# Manual
## Predefined Types

### [`AbstractRNArray`](@id manual-type-normal)

[`AbstractRNArray`](@ref ResizingTools.AbstractRNArray) is a subtype of
`AbstractArray` with predefined `size` by `getsize`:

* `Base.size(A::AbstractRNArray)`: return `getsize(A)`,
* `Base.size(A::AbstractRNArray, d)`: return `getsize(A, d)`
  for `1 <= d <= ndims(A)`, and `1` for `d > ndims(A)`.
### [`AbstractRDArray`](@id manual-type-dense)

[`AbstractRDArray`](@ref ResizingTools.AbstractRDArray) is a subtype of
`DenseArray` with some predefined methods:

* `Base.unsafe_convert(::Ptr{T}, A::AbstractRDArray) where {T}`: return
  `Base.unsafe_convert(Ptr{T}, parent(A)),
* `Base.elsize(::Type{T}) where {T<:AbstractRDArray}`: return
  `Base.elsize(ArrayInterface.parent_type(A))`.

!!! warning
    
    `parent_type(::Type{<:AbstractRDArray})` must be a type with above methods.

## Resizing Methods

### [`sizehint!`](@id manual-methods-sizehint)

This packages provide methods `Base.sizehint!` for `AbstractArray`. You can
`sizehint!` with the same arguments `sizehint!(A, n)` as `Base.sizehint!`,
which suggest that `A` reserve capacity for at least `n`. Besides, for
multi-dimensional arrays, `sizehint!(A, sz::NTuple)` is also a convenient way
which suggests that array `A` reserve capacity for at least `prod(sz)` elements.

### [`resize!`](@id manual-methods-resize)

`resize!` is the core methods of this package, which provide ways to resizing
multi-dimensional arrays. There are two form of `resize!`:

* `resize!(A, sz::Tuple)`: Resize `A` to size `sz`, where `sz` can be a tuple
  accepted by `to_indices` (`Integer`, `Colon`, `AbstractVector`, etc.),
* `resize!(A, d::Integer, I)`: Resize `d`th dimension of `A` to `I`, where `A`
  can be (`Integer`, `Colon`, `AbstractVector`).

There are many interface methods for resizing arrays, most of which depends on
`parent(A)` and related methods like `parent_type`, `resize_parent!`, etc.

## Interfaces

To create a resizable array type, there are some methods required besides of the
[interface of `AbstractArray`](https://docs.julialang.org/en/v1/manual/interfaces/#man-interface-array).

### [Parent](@id manual-interface-parent)

A resizable array type must contain a parent storing data. Thus,
`Base.parent(A::AbstractArray):` which returns the array storing data and
`ArrayInterface.parent_type(::Type{T})` which returns the type of parent must be
defined. Resizing methods like `sizehint!` and `resize!` will effect though 
parent.

### [Size](@id manual-interface-size)

Besides, there are also some methods to access and mutate the size of array.
The most important methods are `ResizingTools.getsize(A)` which returns the size
of `A` and `ResizingTools.size_type(::Type{T})`, which returns the type of
`getsize(A)` and determine the default methods of [`setsize!`](@ref).

There are two available size types now:

* `Dims`: `NTuple` of `Int`s, the normal size type array, and is the default methods. In
  this case the `setsize!` will not change anything,
* [`Size`](@ref): a mutable wrapper of `Dims{N}` with `setindex!` and
  [`set!`](@ref). In this case, `setsize!(A, sz)` will call
  `set!(getsize(A), sz)` and `setsize(A, d, i)` will call `getsize(A)[d] = i`.

However, if the size of array is a mutable field of `Dims`,
`setsize(::Type{S}, A::AbstractArray, sz::Dims{N})` and
`setsize(::Type{S}, A::AbstractArray, d::Int, i::Int)` where `S <: Dims`  must
be defined to mutate the size of array.

### Index transform

In some case, the index of `A` can't be convert to index of its parent, such as 
`A'` for which `A[i, j]' == A'[j, i]`. Thus, in these cases, the index of `A`
must be transformed. Define [`ResizingTools.to_parentinds`](@ref) to do this.

### Example

See the implementation of [`SimpleRDArray`](@ref) for more details.
