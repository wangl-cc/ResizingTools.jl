const Dim = Union{Int,Colon}
const BufferType = Union{Vector,BitVector}

"""
    isresizable(A::AbstractArray)

Check if the type of `A` is resizable.

!!! Note

    `isresizable(A)` for a `Vector` or a `BitVector` will return `false` even
    which can be resized by `resize!(A, n)`.
"""
isresizable(A::AbstractArray) = isresizable(typeof(A))
isresizable(::Type{T}) where {T} = _isresizable(has_parent(T), parent_type(T))
_isresizable(::True, ::Type{T}) where {T} = isresizable(T)
_isresizable(::True, ::Type{<:Vector}) = true
_isresizable(::True, ::Type{<:BitVector}) = true
_isresizable(::False, ::Type) = false


"""
    mapindex(A::AbstractArray, I::Tuple)

Map the index or indices `I` of `A` to index of `parent(A)`.
"""
mapindex

mapindex(::AbstractArray, I::Tuple) = I
mapindex(::AbstractArray, i::Integer, I) = Int(i), I
# adjoint and transpose
mapindex(A::AdjOrTransAbsVec, (i, I)::Tuple) = (checkbounds(A, i, :); (I,)) # don't check I
mapindex(::AdjOrTransAbsMat, (I, J)::Tuple) = (J, I)
mapindex(::AdjOrTrans, i::Integer, I) = ifelse(i == 1, 2, 1), I

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
    setsize!(A::AbstractArray{T,N}, sz) where {T,N}

Set the size of `A` to `sz`
"""
setsize!(A::AbstractArray{T,N}, sz::NTuple{N,Any}) where {T,N} = setsize!(A, _todims(A, sz))
setsize!(A::AbstractArray{T,N}, ::Dims{N}) where {T,N} = A

# setsize!(A, d, i)
"""
    setsize!(A::AbstractArray, d::Integer, i::Integer)

Set the `i`th dimension to `d`.
"""
setsize!(A::AbstractArray, d::Integer, i::Integer) = setsize!(A, Int(d), Int(i))
setsize!(A::AbstractArray{T,N}, d::Int, i::Int) where {T,N} =
    setsize!(A, setindex(size(A), d, i))

# Base.sizehint!(A, sz)
Base.sizehint!(A::AbstractArray{T,N}, sz::NTuple{N,Any}) where {T,N} =
        sizehint!(A, prod(_todims(A, sz)))
function Base.sizehint!(A::AbstractArray, nl::Integer)
    if isresizable(A)
        sizehint!(parent(A), nl)
        return A
    end
    return throw_methoderror(sizehint!, A)
end

# Base.resize!(A, sz)
function Base.resize!(A::AbstractArray{T,N}, sz::NTuple{N,Any}) where {T,N}
    if isresizable(A)
        if parent_type(A) <: BufferType
            return _resize!(A, _todims(sz)...)
        else
            resize!(parent(A), mapindex(A, sz))
            setsize!(A, _todims(sz))
            return A
        end
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
    M = restdim(Colon, nsz...)
    # if only last dim changed
    if M == 1
        nsz[N] > 0 || error("dimension(s) must be > 0")
        nlen = stride(A, N) * nsz[N]
        resize!(parent(A), nlen)
        setsize!(A, nsz[N], N)
        return A
    end
    nsz_int = _todims(A, nsz)
    checksize(A, nsz_int)
    sz_tail = tailn(Val(M), size(A)...)
    nsz_tail = tailn(Val(M), nsz_int...)
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
# _resize! with inds
function _resize!(A::AbstractArray{T,N}, inds::Vararg{Any,N}) where {T,N}
    @boundscheck checkbounds(A, inds...)
    nsz = _todims(A, inds)
    nlen = prod(nsz)
    copyto!(parent(A), A[inds...])
    resize!(parent(A), nlen)
    setsize!(A, nsz)
    return A
end

# Base.resize!(A, d, i)
function Base.resize!(A::AbstractArray, I, i::Integer)
    if isresizable(A)
        if parent_type(A) <: BufferType
            return _resizedim!(A, _todim(I), Int(i))
        else
            i, I = mapindex(A, i, I)
            resize!(parent(A), I, i)
            setsize!(A, _todim(size(A, i), I), i)
            return A
        end
    end
    return throw_methoderror(resize!, A)
end
function _resizedim!(A::AbstractArray, d::Int, i::Int)
    N = ndims(A)
    d == size(A, i) && return A
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
function _resizedim!(A::AbstractArray, _itr, i::Int)
    @boundscheck checkindex(Bool, axes(A, i), _itr) || throw(BoundsError(A))
    itr, d = if eltype(_itr) <: Bool
        _itr, sum(_itr)
    else
        bool_itr = zeros(Bool, size(A, i))
        bool_itr[_itr] .= true
        bool_itr, length(_itr)
    end
    d = sum(itr)
    blk_len, blk_num, batch_num = _blkinfo(A, i)
    nlen = blk_len * d * batch_num
    cpy = similar(A, nlen)
    batch_len = blk_len * blk_num
    δ = 0
    for j in 1:batch_num
        for (k, flag) in enumerate(itr)
            if flag
                soffs = batch_len * (j - 1) + blk_len * (k - 1) + 1
                doffs = soffs + δ
                copyto!(cpy, doffs, parent(A), soffs, blk_len)
            else
                δ = δ - blk_len
            end
        end
    end
    resize!(parent(A), nlen)
    setsize!(A, d, i)
    copyto!(parent(A), cpy)
    return A
end

# aux methods
restdim(::Type{T}, ::T, rest...) where {T} = restdim(T, rest...)
restdim(::Type{T}, rest...) where {T} = length(rest)

function tailn(::Val{N}, item, items...) where {N}
    M = length(items)
    if N == M
        return items
    elseif N > M
        return item, items...
    elseif N < M
        return tailn(Val(N), items...)
    end
end

_accumulate_rec(f, op, init, item) = (init, op(init, f(item)))
_accumulate_rec(f, op, init, item, items...) =
    (init, _accumulate_rec(f, op, op(init, f(item)), items...)...)

# convert no int dims to int dims, but keep colon and itr
_todims(sz::Dims) = sz
_todims(sz::Tuple) = map(_todim, sz)

_todim(dim::Int) = dim
_todim(::Colon) = Colon()
_todim(dim::Integer) = Int(dim)
_todim(itr) = itr # any iterater

# convert no int dims, itr and colon to int dims
_todims(::AbstractArray, sz::Dims) = sz
_todims(A::AbstractArray, sz::Tuple) = map(_todim, size(A), sz)

_todim(::Int, dim::Int) = dim
_todim(dim::Int, ::Colon) = dim
_todim(::Int, dim::Integer) = Int(dim)
_todim(::Int, itr) = eltype(itr) <: Bool ? sum(itr) : length(itr) # any iterater

function _blkinfo(A::AbstractArray, i::Integer)
    i <= ndims(A) || throw(ArgumentError("dim must less than ndims(A)"))
    blk_len = 1
    sz = size(A)
    @inbounds for j in 1:(i-1)
        blk_len *= sz[j]
    end
    batch_num = 1
    @inbounds for j in (i+1):ndims(A)
        batch_num *= sz[j]
    end
    return blk_len, @inbounds(sz[i]), batch_num
end

checksize(::Type{Bool}, A, sz::Dims) = (&)(map(>(0), sz)...)
checksize(A, sz::Dims) = checksize(Bool, A, sz) || error("dimension(s) must be > 0")

setindex(A::Tuple, v, i::Int) = map_enumerate((j, Aj) -> ifelse(j == i, v, Aj), A)

map_enumerate(f, t::NTuple{N}) where {N} = map(f, ntuple(identity, Val(N)), t)

throw_methoderror(f, A::AbstractArray{N}) where {N} =
    error("`$f` is not defined for `$(typeof(A))`")
