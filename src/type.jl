"""
    AbstractRDArray{T,N} <: DenseArray{T,N}

`N`-dimensional resizable dense array with elements of type `T` with some
pre-defined array methods.
"""
abstract type AbstractRDArray{T,N} <: DenseArray{T,N} end
Base.IndexStyle(::Type{<:AbstractRDArray}) = IndexLinear()
Base.length(A::AbstractRDArray) = length(parent(A))
Base.size(A::AbstractRDArray{T,N}) where {T,N} = convert(NTuple{N,Int}, getsize(A))
Base.size(A::AbstractRDArray, d::Integer) = d < 1 ? throw(BoundsError()) :
                                            d > ndims(A) ? 1 : @inbounds getsize(A, d)
Base.getindex(A::AbstractRDArray, i::Int) = parent(A)[i]
Base.setindex!(A::AbstractRDArray, v, i::Int) = parent(A)[i] = v
Base.unsafe_convert(::Type{Ptr{T}}, A::AbstractRDArray{T}) where {T} =
    Base.unsafe_convert(Ptr{T}, parent(A))
Base.elsize(::Type{T}) where {T<:AbstractRDArray} = Base.elsize(parent_type(T))

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
@inline getsize(A::SimpleRDArray) = A.sz
Base.@propagate_inbounds getsize(A::SimpleRDArray, d::Int) = A.sz[d]
@inline setsize!(A::SimpleRDArray{T,N}, sz::Dims{N}) where {T,N} = set!(A.sz, sz)
Base.@propagate_inbounds setsize!(A::SimpleRDArray, dim::Int, i::Int) = A.sz[i] = dim
