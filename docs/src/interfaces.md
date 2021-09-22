# Resizing Interfaces

## Resizable Dense Array

[`AbstractRDArray`](@ref ResizingTools.AbstractRDArray) is a subtype of
`DenseArray` with some predefined methods. So if an array type `RDArray`
is a subtype of `DenseArray`, a convenient way is to make it a subtype
of `AbstractRDArray`, the defined methods below:

| Required methods                                                     | Brief description                                                   |
| :------------------------------------------------------------------- | :------------------------------------------------------------------ |
| `Base.parent(A::RDArray)`                                            | Returns a dense array contining the data, which must be resizable. |
| `ArrayInterface.parent_type(::Type{<:RDArray})`                      | Returns the type of its parent                                      |
| `ResizingTools.getsize(A::RDArray{T,N}) where {T,N}`                 | Returns the dimensions of `A`                                       |

| Optional methods                                     | Default definition                        | Brief description                                      |
| :--------------------------------------------------- | :---------------------------------------- | :----------------------------------------------------- |
| `ResizingTools.getsize(A::RDArray, i::Int)`          | `getsize(A)[i]`                           | Returns the `i`th dimension of `A`                     |
| `ResizingTools.setsize!(A::RDArray{T,N}, dims::Dims{N}) where {T,N}` | `A` (do nothing).         | Mutates the dimensions of `A` into `dims`             |
| `ResizingTools.has_setsize(::Type{T}) where {T<:RDArray}` | `false` | Whether `setsize!(A::T, dims)` were defined. if it's `true`, the default `setsize!(A, d, i)` will do nothing. |
| `ResizingTools.setsize!(A::RDArray, d::Int, i::Int)` | `setsize!(A, setindex(getsize(A), d, i))` | Mutates `i`th dimension of `A` into `dim`              |
| `ResizingTools.mapindex(A::RDArray, I::Tuple)`       | `I`                                       | Map the index(s) `I` of `A` to index(s) of `parent(A)` |
| `ResizingTools.mapindex(A::RDArray, i, I)`           | `I`                                       | Map the `i`-dim index(s) `I` of `A` to index(s) of `parent(A)` |

Note: To `resize!` an array, `parent_type` of the array must be resizable such as `Vector` or `SimpleRDArray`.

## Normal Case

If your array type is not a dense array, or you don't want to make it a subtype
of `AbstractRDArray`. You must define more methods in
[Julia array interfaces](https://docs.julialang.org/en/v1/manual/interfaces/#man-interface-array).
