"""
    AbstractSize{N}

Supertype for all array sizes.
"""
abstract type AbstractSize{N} end

const SizeType{N} = Union{AbstractSize{N}, Dims{N}}

"""
    Size{N} <: AbstractSize{N}

Size type for resizable arrays, which is a mutable wrapper of `Dims{N}` to
represent the dimension of an resizable array. Mutate `d`th dimension to `n` by
`sz[d] = n` mutate the whole dimensions to `nsz` by `set!(sz, nsz)`.
"""
mutable struct Size{N} <: AbstractSize{N}
    sz::Dims{N}
end
@inline Size(I::Int...) = Size(I)
@inline Size(A::AbstractArray) = Size(size(A))

# use SizeOrTuple instead of SizeType{N} to avoid override the methods for tuple
const SizeOrTuple = Union{Size,Tuple}
_totuple(sz::Size) = sz.sz
_totuple(tp::Tuple) = tp

@inline Base.length(::Size{N}) where {N} = N
@inline Base.convert(::Type{T}, sz::Size) where {T<:Tuple} = convert(T, sz.sz)
@inline Base.:(==)(t1::SizeOrTuple, t2::SizeOrTuple) = _totuple(t1) == _totuple(t2)

"""
    set!(sz::Size{N}, nsz::NTuple{N,Integer})

Set `sz` to `nsz`.

# Example
```jldoctest
julia> sz = Size(1, 2, 3)
Size{3}((1, 2, 3))

julia> set!(sz, (3, 2, 1))
Size{3}((3, 2, 1))
```
"""
set!(sz::Size{N}, nsz::NTuple{N,Integer}) where {N} = set!(sz, convert(Dims{N}, nsz))
set!(sz::Size{1}, nsz::Dims{1}) = (sz[1] = nsz[1]; sz)
set!(sz::Size{2}, nsz::Dims{2}) = (sz[1] = nsz[1]; sz[2] = nsz[2]; sz)
set!(sz::Size{3}, nsz::Dims{3}) = (sz[1] = nsz[1]; sz[2] = nsz[2]; sz[3] = nsz[3]; sz)
set!(sz::Size{N}, nsz::Dims{N}) where {N} = sz.sz = nsz

# The below two methods is a modification of `MArray` in `StaticArrays.jl`
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
size_type(::Type{T}) where {T<:AbstractArray} = Dims{ndims(T)}

# setsize!(A, sz)
"""
    setsize!(A::AbstractArray{T,N}, sz) where {T,N} -> AbstractArray

Set the size of `A` to `sz`.
"""
setsize!(A::AbstractArray{T,N}, sz::NTuple{N,Any}) where {T,N} =
    setsize!(size_type(A), A, to_dims(sz))

@inline setsize!(::Type{S}, A::AbstractArray, ::Dims{N}) where {N,S<:Dims{N}} = A
@inline setsize!(::Type{S}, A::AbstractArray{T,N}, sz::Dims{N}) where {T,N,S<:Size{N}} =
    (set!(getsize(A)::S, sz); A)

# setsize!(A, d, i)
"""
    setsize!(A::AbstractArray, d::Integer, n) -> AbstractArray

Set the `d`th dimension to `n`.
"""
Base.@propagate_inbounds setsize!(A::AbstractArray, d::Integer, n) =
    setsize!(size_type(A), A, Int(d), to_dims(n))

@inline setsize!(::Type{S}, A::AbstractArray, ::Int, ::Int) where {S<:Dims} = A
setsize!(::Type{S}, A::AbstractArray{T,N}, d::Int, n::Int) where {T,N,S<:Size{N}} =
    (Base.@_propagate_inbounds_meta; getsize(A)[d] = n; A) # meta to avoid too long line

@inline setindex(A::Tuple, v, i::Int) = ntuple(j -> ifelse(j == i, v, A[j]), Val(length(A)))

"""
    to_dims(inds::Tuple) -> Dims

Convert the given indices to `Dims`.

!!! note

    The given indices should be a return value of `to_indices`.
    If `inds[i]` is an `Integer`, this function would converted it to `Int`;
    If `inds[i]` is an `AbstractVector`, this function would return its length.
"""
to_dims(inds::Tuple) = map(to_dims, inds)::Dims
to_dims(inds::Dims) = inds
to_dims(ind::AbstractVector) = length(ind)::Int
to_dims(ind::Integer) = Int(ind)