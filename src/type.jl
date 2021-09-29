"""
    AbstractRDArray{T,N} <: DenseArray{T,N}

`N`-dimensional resizable dense array with elements of type `T` with some
pre-defined array methods.
"""
abstract type AbstractRDArray{T,N} <: DenseArray{T,N} end

"""
    AbstractRNArray{T,N} <: AbstractArray{T,N}

`N`-dimensional resizable (no-dense) array with elements of type `T` with some
pre-defined array methods.
"""
abstract type AbstractRNArray{T,N} <: AbstractArray{T,N} end

const ResizableArray{T,N} = Union{AbstractRDArray{T,N},AbstractRNArray{T,N}}

Base.size(A::ResizableArray{T,N}) where {T,N} = convert(NTuple{N,Int}, getsize(A))
Base.size(A::ResizableArray, d::Integer) = d < 1 ? throw(BoundsError()) :
                                           d > ndims(A) ? 1 : @inbounds getsize(A, d)
# DenseArray only
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
Base.IndexStyle(::Type{<:SimpleRDArray}) = IndexLinear()
Base.@propagate_inbounds Base.getindex(A::SimpleRDArray, i::Int) = parent(A)[i]
Base.@propagate_inbounds Base.getindex(A::SimpleRDArray, I::AbstractArray) = parent(A)[I]
Base.@propagate_inbounds Base.setindex!(A::SimpleRDArray, v, i::Int) = parent(A)[i] = v
Base.@propagate_inbounds Base.setindex!(A::SimpleRDArray, v, i::AbstractArray) =
    parent(A)[i] = v
Base.parent(A::SimpleRDArray) = A.parent
ArrayInterface.parent_type(::Type{<:SimpleRDArray{T,N}}) where {T,N} = Vector{T}
@inline getsize(A::SimpleRDArray) = A.sz
Base.@propagate_inbounds getsize(A::SimpleRDArray, d::Int) = A.sz[d]
@inline setsize!(A::SimpleRDArray{T,N}, sz::Dims{N}) where {T,N} = set!(A.sz, sz)
Base.@propagate_inbounds setsize!(A::SimpleRDArray, d::Int, n::Int) = A.sz[d] = n
