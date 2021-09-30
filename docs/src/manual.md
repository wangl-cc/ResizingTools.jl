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
  `Base.unsafe_convert(Ptr{T}, parent(A))
* `Base.elsize(::Type{T}) where {T<:AbstractRDArray}`: return
  `Base.elsize(ArrayInterface.parent_type(A))`

## Resizing Methods

### [`sizehint!`](@id manual-methods-sizehint)

This packages provide methods `Base.sizehint!` for `AbstractArray`. You can
`sizehint!` with the same arguments `sizehint!(A, n)` as `Base.sizehint!`,
which suggest that `A` reserve capacity for at least `n`. Besides, for
multi-dimensional arrays, `sizehint!(A, sz::NTuple)` is also a convenient way
which suggests that array `A` reserve capacity for at least `prod(sz)` elements.
Besides, for non-dense arrays, you can override `sizehint!(A, sz::Dims{N})` to
more complicate `sizehint!`.

### [`resize!`](@id manual-methods-resize)

`resize!` is the core methods of this package, which provide ways to resizing
multi-dimensional arrays. There are two form of `resize!`:

* `resize!(A, sz::Tuple)`: Resize `A` to size `sz`, where `sz` can be a tuple
  accepted by `to_indices` (`Integer`, `Colon`, `AbstractVector`, etc.),
* `resize!(A, d::Integer, I)`: Resize `d`th dimension of `A` to `I`, where `A`
  can be (`Integer`, `Colon`, `AbstractVector`).

There are many interface methods for resizing arrays, most of which depends on
`parent(A)` and related methods like `parent_type`, `resize_parent!`, etc.

More about interface, see [interfaces](@ref Interfaces).