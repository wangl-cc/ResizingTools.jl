"""
    Size{N}

A mutable warpper of `NTuple{N,Int}` used to represent the dimension of an
resizable array. Mutate 'i'th dimension to `ndim` by `sz[i] = ndim` mutate the
whole dimensions to `ndims` by `set!(sz, ndims)`.
"""
mutable struct Size{N}
    sz::NTuple{N,Int}
end
@inline Size(I::Int...) = Size(I)
@inline Size(A::AbstractArray) = Size(size(A))

const SizeOrTuple = Union{Size,Tuple}
_totuple(sz::Size) = sz
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
