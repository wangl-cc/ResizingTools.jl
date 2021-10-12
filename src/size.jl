"""
    AbstractSize

Supertype for array sizes. See the interface section for more information.
"""
abstract type AbstractSize end

const SizeType = Union{AbstractSize, Dims}

"""
    NoneSize <: AbstractSize

Size type for arrays without specific size property.
"""
struct NoneSize <: AbstractSize end

"""
    Size{N} <: AbstractSize{N}

Size type for resizable arrays, which is a mutable warpper of `NTuple{N,Int}` to
represent the dimension of an resizable array. Mutate 'd'th dimension to `n` by
`sz[d] = n` mutate the whole dimensions to `nsz` by `set!(sz, nsz)`.
"""
mutable struct Size{N} <: AbstractSize
    sz::NTuple{N,Int}
end
@inline Size(I::Int...) = Size(I)
@inline Size(A::AbstractArray) = Size(size(A))

const SizeOrTuple = Union{Size,Tuple}
_totuple(sz::Size) = sz.sz
_totuple(tp::Tuple) = tp

@inline Base.length(::Size{N}) where {N} = N
@inline Base.convert(::Type{T}, sz::Size) where {T<:Tuple} = convert(T, sz.sz)
@inline Base.:(==)(t1::SizeOrTuple, t2::SizeOrTuple) = _totuple(t1) == _totuple(t2)
set!(sz::Size{1}, nsz::NTuple{1,Int}) = (sz[1] = nsz[1]; sz)
set!(sz::Size{2}, nsz::NTuple{2,Int}) = (sz[1] = nsz[1]; sz[2] = nsz[2]; sz)
set!(sz::Size{3}, nsz::NTuple{3,Int}) = (sz[1] = nsz[1]; sz[2] = nsz[2]; sz[3] = nsz[3]; sz)
set!(sz::Size{N}, nsz::NTuple{N,Int}) where {N} = sz.sz = nsz

# The below two methods is a modifaction of `MArray` in `StaticArrays.jl`
# https://github.com/JuliaArrays/StaticArrays.jl/blob/master/src/MArray.jl#L80
function Base.getindex(sz::Size{N}, i::Int) where {N}
    @boundscheck 1 <= i <= N || throw(BoundsError(sz, i))
    return GC.@preserve sz unsafe_load(
        Base.unsafe_convert(Ptr{Int}, pointer_from_objref(sz)),
        i,
    )
end

function Base.setindex!(sz::Size{N}, v, i::Int) where {N}
    @boundscheck 1 <= i <= N || throw(BoundsError(sz, i))
    return GC.@preserve sz unsafe_store!(
        Base.unsafe_convert(Ptr{Int}, pointer_from_objref(sz)),
        convert(Int, v),
        i,
    )
end

# getsize
"""
    getsize(A::AbstractArray, [dim])

Returns the dimensions of `A` unlike `size` which may not return a
`Dims{N}`.
"""
getsize

@inline getsize(A::AbstractArray) = size(A) # return `size(A)` by default
@inline getsize(A::AbstractArray, d::Integer) = getsize(A, Int(d))
Base.@propagate_inbounds getsize(A::AbstractArray, d::Int) = getsize(A)[d]

"""
    size_type(A::AbstractArray)

Get the size type of `A`, determine the methods of `setsize!`. The default
`size_type` is `NoneSize`, which means `setsize!` will "do nothing".
"""
size_type(A::AbstractArray) = size_type(typeof(A))
size_type(::Type{<:AbstractArray}) = NoneSize

# setsize!(A, sz)
"""
    setsize!(A::AbstractArray{T,N}, sz) where {T,N} -> AbstractArray

Set the size of `A` to `sz`.
"""
setsize!(A::AbstractArray{T,N}, sz::NTuple{N,Any}) where {T,N} =
    setsize!(size_type(A), A, _to_size(sz))

@inline setsize!(::Type{S}, A::AbstractArray, ::Dims{N}) where {S<:NoneSize,N} = A
# setsize!(::Type{S}, A::AbstractArray{T,N}, ::Dims{N}) where {T,N,S<:Dims{N}} (by user)
@inline setsize!(::Type{S}, A::AbstractArray{T,N}, sz::Dims{N}) where {T,N,S<:Size{N}} =
    (set!(getsize(A), sz); A)

# setsize!(A, d, i)
"""
    setsize!(A::AbstractArray, d::Integer, n) -> AbstractArray

Set the `d`th dimension to `n`.
"""
Base.@propagate_inbounds setsize!(A::AbstractArray, d::Integer, n) =
    setsize!(size_type(A), A, Int(d), _to_size(n))

@inline setsize!(::Type{S}, A::AbstractArray, ::Int, ::Int) where {S<:NoneSize} = A
@inline setsize!(::Type{S}, A::AbstractArray{T,N}, d::Int, n::Int) where {T,N,S<:Dims{N}} =
    setsize!(S, A, setindex(getsize(A), n, d))
setsize!(::Type{S}, A::AbstractArray{T,N}, d::Int, n::Int) where {T,N,S<:Size{N}} =
    (Base.@_propagate_inbounds_meta; getsize(A)[d] = n; A) # meta to aviod too long line

@inline setindex(A::Tuple, v, i::Int) = ntuple(j -> ifelse(j == i, v, A[j]), Val(length(A)))

_to_size(inds::Tuple) = map(_to_size, inds)
_to_size(inds::Dims) = inds
_to_size(ind) = length(ind)
_to_size(ind::Integer) = Int(ind)