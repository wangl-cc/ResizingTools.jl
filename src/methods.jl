const Dim = Union{Int,Colon}
const Resizable = Union{Vector,BitVector}

# getsize
"""
    getsize(A::AbstractArray, [dim])

Return the dimensions of `A` unlike `size` which may not return a
`NTuple{N,Int}`. For a [`AbstractRDArray`](@ref), `convert(Tuple, getsize(A))`
is the default implementation of `size(A)`.
"""
getsize(A::AbstractArray, d::Integer) = getsize(A, Int(d))
getsize(A::AbstractArray, d::Int) = getsize(A)[d]
getsize(A::AbstractArray) = throw_methoderror(getsize, A)

# setsize!(A, sz)
"""
    setsize!(A::AbstractArray{T,N}, sz::Dims{N}) where {T,N}
    setsize!(A::AbstractArray, d::Integer, i::Integer)

Mutate the size of `A` to `sz`.
"""
setsize!
# setsize!(A, sz)
setsize!(A::AbstractArray{T,N}, sz::NTuple{N,Dim}) where {T,N} = setsize!(A, _todims(A, sz))
setsize!(A::AbstractArray{T,N}, ::Dims{N}) where {T,N} = throw_methoderror(setsize!, A)

# setsize!(A, d, i)
setsize!(A::AbstractArray, d::Integer, i::Integer) = setsize!(A, Int(d), Int(i))
setsize!(A::AbstractArray{T,N}, d::Int, i::Int) where {T,N} =
    setsize!(A, setindex(getsize(A), d, i))

# Base.sizehint!(A, sz)
function Base.sizehint!(A::AbstractArray{T,N}, sz::NTuple{N,Dim}) where {T,N}
    if Bool(has_parent(A))
        return _sizehint!(A, _todims(A, sz)...)
    end
    return throw_methoderror(sizehint!, A)
end

_sizehint!(A::AbstractArray{T,N}, sz::Vararg{Int,N}) where {T,N} =
    (sizehint!(parent(A), prod(sz)); A)
_sizehint!(A::AbstractArray, n::Int) = (sizehint!(parent(A), n); A)

# Base.resize!(A, sz)
function Base.resize!(A::AbstractArray{T,N}, sz::NTuple{N,Dim}) where {T,N}
    if Bool(has_parent(A))
        return _resize!(A, _todims(sz)...) # without A to preserve Colon
    end
    return throw_methoderror(resize!, A)
end

# resize vector will not move any element
function _resize!(A::AbstractVector{T}, n::Int) where {T}
    resize!(parent(A), n) # resize! buffer by Base.resize!
    setsize!(A, n, 1)
    return A
end
# resize array with Int sz
function _resize!(A::AbstractArray{T,N}, nsz::Vararg{Int,N}) where {T,N}
    checksize(A, nsz)
    # resize parent if parent is not Resizable
    parent_type(A) <: Resizable || begin
        resize!(parent(A), nsz)
        setsize!(A, nsz)
        return A
    end
    # if parent is Resizable
    sz = size(A)
    nsz == sz && return A # if sz not change
    if nsz[1:N-1] == sz[1:N-1] # if only last dim changed
        resize!(parent(A), prod(nsz))
        setsize!(A, nsz[N], N)
        return A
    end
    # normal case
    ssz = map(min, sz, nsz)
    # step 1: get reserved elements
    src = if ssz != sz # some elements will be drop
        A[map(Base.OneTo, ssz)...]
    else # all elements will be reserved
        copy(A)
    end
    # step 2: resize A for enough capacity
    resize!(parent(A), prod(nsz))
    setsize!(A, nsz)
    # step 3: get dst region of A
    dst = view(A, map(Base.OneTo, ssz)...)
    # step 4: copy elements
    copyto!(dst, src) # this copy is not fastest
    return A
end
# resize with Colon
function _resize!(A::AbstractArray{T,N}, nsz::Vararg{Dim,N}) where {T,N}
    # resize parent if parent is not Resizable
    parent_type(A) <: Resizable || begin
        resize!(parent(A), nsz)
        setsize!(A, nsz)
        return A
    end
    M = _getM(nsz...)
    # if only last dim changed
    if M == 1 && nsz[N] isa Int
        nsz[N] > 0 || error("dimension(s) must be > 0")
        nlen = stride(A, N) * nsz[N]
        resize!(parent(A), nlen)
        setsize!(A, nsz[N], N)
        return A
    end
    nsz_int = _todims(A, nsz)
    checksize(A, nsz_int)
    sz_tail = tailn(size(A), Val(N - M))
    nsz_tail = tailn(nsz_int, Val(N - M))
    nlen = prod(nsz_int)
    cpy = similar(A, nlen)
    blocklen = stride(A, N - M + 1)
    ssz_tail = map(min, sz_tail, nsz_tail)
    if ssz_tail == sz_tail
        copyto!(cpy, parent(A))
    else
        strds = _accumulate_rec(identity, *, 1, sz_tail...)
        for (i, sub) in enumerate(CartesianIndices(ssz_tail))
            ind = mapreduce((strd, i) -> strd * (i - 1), +, strds, sub.I) + 1
            copyto!(
                cpy,
                blocklen * (i - 1) + 1,
                parent(A),
                blocklen * (ind - 1) + 1,
                blocklen,
            )
        end
    end
    resize!(parent(A), nlen)
    setsize!(A, nsz)
    if ssz_tail == nsz_tail
        copyto!(parent(A), cpy)
    else
        nstrds = _accumulate_rec(identity, *, 1, nsz_tail...)
        for (i, sub) in enumerate(CartesianIndices(ssz_tail))
            ind = mapreduce((strd, i) -> strd * (i - 1), +, nstrds, sub.I) + 1
            copyto!(
                parent(A),
                blocklen * (ind - 1) + 1,
                cpy,
                blocklen * (i - 1) + 1,
                blocklen,
            )
        end
    end
    return A
end
_resize!(A::AbstractArray{T,N}, ::Vararg{Colon,N}) where {T,N} = A
# Base.resize!(A, d, i)
function Base.resize!(A::AbstractArray, d, i::Integer)
    if Bool(has_parent(A))
        return _resize_dim!(A, Int(d), Int(i))
    end
    return throw_methoderror(resize!, A)
end
function _resize_dim!(A::AbstractArray, d::Int, i::Int)
    N = ndims(A)
    d == size(A)[i] && return A
    if i == N
        resize!(parent(A), stride(A, N) * d)
        setsize!(A, d, i)
        return A
    end
    blk_len, blk_num, batch_num = _blkinfo(A, i)
    nlen = blk_len * d * batch_num
    cpy = similar(A, nlen)
    batch_len = blk_len * blk_num
    sbatch_len = blk_len * min(d, blk_num)
    δ = 0
    for j in 1:batch_num
        soffs = batch_len * (j - 1) + 1
        doffs = soffs + δ
        copyto!(cpy, doffs, parent(A), soffs, sbatch_len)
        δ = δ + blk_len * (d - blk_num)
    end
    resize!(parent(A), nlen)
    setsize!(A, d, i)
    copyto!(parent(A), cpy)
    return A
end

# TODO: deletaat, push, insert

# aux methods
_getM(::Colon, rest::Dim...) = _getM(rest...)
_getM(::Vararg{Dim,M}) where {M} = M

tailn(t::Tuple, ::Val{0}) = t
tailn(t::Tuple, ::Val{1}) = Base.tail(t)
tailn(t::Tuple, ::Val{N}) where {N} = tailn(Base.tail(t), Val(N - 1))

_accumulate_rec(f, op, init, item) = (init, op(init, f(item)))
_accumulate_rec(f, op, init, item, items...) =
    (init, _accumulate_rec(f, op, op(init, f(item)), items...)...)

# convert no int dims to int dims, but keep colon
_todims(sz::Dims) = sz
_todims(sz::Tuple) = map(_todim, sz)

# convert no int dims and colon to int dims
_todims(::AbstractArray, sz::Dims) = sz
_todims(A::AbstractArray, sz::Tuple) = map(_todim, size(A), sz)

_todim(dim::Int) = dim
_todim(::Colon) = Colon()
_todim(dim::Integer) = Int(dim)

_todim(::Int, dim::Int) = dim
_todim(dim::Int, ::Colon) = dim
_todim(::Int, dim::Integer) = Int(dim)

function _blkinfo(A::AbstractArray, n::Integer)
    n <= ndims(A) || throw(ArgumentError("dim must less than ndims(A)"))
    blk_len = 1
    sz = size(A)
    @inbounds for i in 1:(n-1)
        blk_len *= sz[i]
    end
    batch_num = 1
    @inbounds for i in (n+1):ndims(A)
        batch_num *= sz[i]
    end
    return blk_len, @inbounds(sz[n]), batch_num
end

checksize(::Type{Bool}, A, sz::Dims) = (&)(map(>(0), sz)...)
checksize(A, sz::Dims) = checksize(Bool, A, sz) || error("dimension(s) must be > 0")

setindex(A::Tuple, v, i::Int) = map_enumerate((j, Aj) -> ifelse(j == i, v, Aj), A)

map_enumerate(f, t::NTuple{N}) where {N} = map(f, ntuple(identity, Val(N)), t)

throw_methoderror(f, A::AbstractArray{N}) where {N} =
    error("`$f` is not defined for `$(typeof(A))`")
