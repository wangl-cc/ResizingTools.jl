"""
    AbstractRDArray{T,N} <: DenseArray{T,N}

`N`-dimensional resizable dense array with elements of type `T` with some
pre-defined array methods.

Declared a subtype like 'RDArray' and defined required methods:
* `Base.parent(A::RDArray)`: return a dense array containing the data.
* `ArrayInterface.parent_type(::Type{<:RDArray})`: return the type of its parent.
* `ResizingTools.getsize(A::RDArray{T,N}) where {T,N}`: return sizes of `A`,
* `ResizingTools.setsize!(A::RDArray{T,N}, dim::Dims{N}) where {T,N}`:
  mutate the return of `getsize(A)` to `dims`.
and optional methods:
* `ResizingTools.getsize(A::RDArray, i::Int)`: like `size(A, i)`.
* `ResizingTools.setsize!(A::RDArray, dim::Int, i::Int)`: mutate `size(A, i)`
  to `dim`.
Then your type `RDArray` will works like a dense array but resizable.
"""
abstract type AbstractRDArray{T,N} <: DenseArray{T,N} end
Base.IndexStyle(::Type{<:AbstractRDArray}) = IndexLinear()
Base.length(A::AbstractRDArray) = length(parent(A))
Base.size(A::AbstractRDArray{T,N}) where {T,N} = convert(NTuple{N,Int}, getsize(A))
Base.size(A::AbstractRDArray, d::Integer) = getsize(A, d)
Base.getindex(A::AbstractRDArray, i::Int) = parent(A)[i]
Base.setindex!(A::AbstractRDArray, v, i::Int) = parent(A)[i] = v
Base.unsafe_convert(::Type{Ptr{T}}, A::AbstractRDArray{T}) where {T} =
    Base.unsafe_convert(Ptr{T}, parent(A))
Base.elsize(::Type{<:AbstractRDArray{T}}) where {T} = sizeof(T)

"""
    SimpleRDArray{T,N} <: AbstractRDArray{T,N}

A simple implementation of resizable dense array.
"""
struct SimpleRDArray{T,N} <: AbstractRDArray{T,N}
    parent::Vector{T}
    sz::Size{N}
end
function SimpleRDArray(A::AbstractArray)
    vec = Vector{eltype(A)}(undef, length(A))
    copyto!(vec, A)
    sz = Size(A)
    return SimpleRDArray(vec, sz)
end
Base.parent(A::SimpleRDArray) = A.parent
ArrayInterface.parent_type(::Type{<:SimpleRDArray{T,N}}) where {T,N} = Vector{T}
getsize(A::SimpleRDArray) = A.sz
getsize(A::SimpleRDArray, d::Int) = A.sz[d]
setsize!(A::SimpleRDArray{T,N}, sz::Dims{N}) where {T,N} = set!(A.sz, sz)
setsize!(A::SimpleRDArray{T,N}, dim::Int, i::Int) where {T,N} = A.sz[i] = dim
