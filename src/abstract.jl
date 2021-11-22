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

Base.size(A::ResizableArray{T,N}) where {T,N} = convert(Dims{N}, getsize(A))
Base.size(A::ResizableArray, d::Integer) =
    d < 1 ? throw(BoundsError()) : d > ndims(A) ? 1 : @inbounds getsize(A, d)
# DenseArray only
Base.unsafe_convert(::Type{Ptr{T}}, A::AbstractRDArray{T}) where {T} =
    Base.unsafe_convert(Ptr{T}, parent(A))
Base.elsize(::Type{T}) where {T<:AbstractRDArray} = Base.elsize(parent_type(T))

ArrayInterface.strides(A::AbstractRDArray) = (StaticInt(1), Base.tail(strides(A))...)
ArrayInterface.strides(A::AbstractRDArray, dim::Integer) = stride(A, Int(dim))

ArrayInterface.stride_rank(::Type{T}) where {T<:AbstractRDArray} =
    Static.nstatic(Val(ndims(T)))
ArrayInterface.dense_dims(::Type{T}) where {T<:AbstractRDArray} =
    ntuple(_ -> True(), Val(ndims(T)))
ArrayInterface.axes_types(::Type{T}) where {T<:AbstractRDArray} =
    NTuple{ndims(T), Base.OneTo{Int}}
