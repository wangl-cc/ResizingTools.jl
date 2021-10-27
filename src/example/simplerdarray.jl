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
size_type(::Type{<:SimpleRDArray{T,N}}) where {T,N} = Size{N}
@inline getsize(A::SimpleRDArray) = A.sz
