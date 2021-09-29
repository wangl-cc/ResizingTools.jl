const Dim = Union{Int,Base.Slice}
const BufferType = Union{Vector,BitVector}

"""
    isresizable(A::AbstractArray)

Check if the type of `A` is resizable.

!!! info

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
    toparentinds(A::AbstractArray, Is::Tuple) -> Is′

Convert the index(s) `Is` of `A` to index(s) `Is′` of `parent(A)`.
"""
to_parentinds(::AbstractArray, Is::Tuple) = Is
"""
    toparentinds(A::AbstractArray, i::Integer, I) -> (i′, I′)

Convert the index(s) `I` at `d`th dimension of `A` to index(s) `I′` at `d′`th
dimentsion of `parent(A)`.
"""
to_parentinds(::AbstractArray, d::Integer, I) = Int(d), I
# impl of adjoint and transpose
to_parentinds(A::AdjOrTransAbsVec, (i, J)::Tuple) = (check_dimbounds(A, 1, i); (J,))
to_parentinds(::AdjOrTransAbsMat, (I, J)::Tuple) = (J, I)
to_parentinds(::AdjOrTrans, i::Integer, I) = ifelse(i == 1, 2, 1), I

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
setsize!(A::AbstractArray{T,N}, sz::NTuple{N,Any}) where {T,N} =
    setsize!(A, _to_size(sz))
setsize!(A::AbstractArray{T,N}, ::Dims{N}) where {T,N} = A

has_setsize(t) = has_setsize(typeof(t))
has_setsize(::Type{<:AbstractArray}) = false

# setsize!(A, d, i)
"""
    setsize!(A::AbstractArray, d::Integer, n)

Set the `d`th dimension to `n`.
"""
setsize!(A::AbstractArray, d::Integer, n) = setsize!(A, Int(d), _to_size(n))
function setsize!(A::AbstractArray, d::Int, n::Int)
    if has_setsize(A)
        return setsize!(A, setindex(size(A), d, n))
    else
        return A
    end
end

# Base.sizehint!(A, sz)
Base.sizehint!(A::AbstractArray{T,N}, sz::NTuple{N,Any}) where {T,N} =
    sizehint!(A, prod(_to_size(sz)))
function Base.sizehint!(A::AbstractArray, nl::Integer)
    if isresizable(A)
        sizehint!(parent(A), nl)
        return A
    end
    return throw_methoderror(sizehint!, A)
end

"""
    Base.resize!(A::AbstractArray{T,N}, sz)

Resize `A` to `sz`. `sz` can be a tuple of integer or Colon or iterator.
"""
function Base.resize!(A::AbstractArray{T,N}, dims::NTuple{N,Any}, ::B=False()) where {T,N,B}
    dims′ = _to_indices(A, dims, B())
    if isresizable(A)
        if parent_type(A) <: BufferType
            return resize_buffer!(A, to_indices(A, dims′)...)
        else
            resize!(parent(A), to_parentinds(A, dims′), True())
            setsize!(A, dims′)
            return A
        end
    end
    return throw_methoderror(resize!, A)
end

"""
    resize_buffer!(A::AbstractArray, nsz...)

Implementation of `resize!(A, nsz)` where `perent(A)` is a `Vector`.
"""
resize_buffer!
# resize vector will not move any element
function resize_buffer!(A::AbstractVector{T}, n::Int) where {T}
    checksize(A, (n,))
    resize!(parent(A), n) # resize! buffer by Base.resize!
    setsize!(A, 1, n)
    return A
end
# resize array with Int sz
function resize_buffer!(A::AbstractArray{T,N}, nsz::Vararg{Int,N}) where {T,N}
    checksize(A, nsz)
    sz = size(A)
    nsz == sz && return A # if sz not change
    if nsz[1:N-1] == sz[1:N-1] # if only last dim changed
        resize!(parent(A), prod(nsz))
        setsize!(A, N, nsz[N])
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
function resize_buffer!(A::AbstractArray{T,N}, dims::Vararg{Dim,N}) where {T,N}
    M = restdim(Base.Slice, dims...)
    # if only last dim changed
    if M == 1
        dims[N] > 0 || error("dimension(s) must be > 0")
        nlen = stride(A, N) * dims[N]
        resize!(parent(A), nlen)
        setsize!(A, N, dims[N])
        return A
    end
    nsz = _to_size(dims)
    checksize(A, nsz)
    sz_tail = tailn(Val(M), size(A)...)
    nsz_tail = tailn(Val(M), nsz...)
    nlen = prod(nsz)
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
resize_buffer!(A::AbstractArray{T,N}, ::Vararg{Base.Slice,N}) where {T,N} = A
# _resize! with inds
function resize_buffer!(A::AbstractArray{T,N}, inds::Vararg{Any,N}) where {T,N}
    @boundscheck checkbounds(A, inds...)
    nsz = _to_size(inds)
    nlen = prod(nsz)
    copyto!(parent(A), A[inds...])
    resize!(parent(A), nlen)
    setsize!(A, nsz)
    return A
end

"""
    Base.resize!(A::AbstractArray{T,N}, d::Integer, I)

Resize the `d`th dimension to `I`, where `I` can be an integer or a colon or an iterator.
"""
function Base.resize!(A::AbstractArray, d::Integer, I)
    if isresizable(A)
        if parent_type(A) <: BufferType
            return resize_buffer_dim!(A, Int(d), Base.to_index(I))
        else
            d′, Iʹ = to_parentinds(A, d, Base.to_index(I))
            resize!(parent(A), d′, Iʹ)
            setsize!(A, d′, Iʹ)
            return A
        end
    end
    return throw_methoderror(resize!, A)
end
Base.resize!(A::AbstractArray, ::Integer, ::Colon) = A

"""
    resize_buffer_dim!(A::AbstractArray, d::Int, I) 

Implementation of `resize!(A, d, I)` where `perent(A)` is a `Vector`.
"""
resize_buffer_dim!

function resize_buffer_dim!(A::AbstractArray, d::Int, n::Int)
    N = ndims(A)
    n == size(A, d) && return A
    if d == N
        resize!(parent(A), stride(A, N) * n)
        setsize!(A, N, n)
        return A
    end
    blk_len, blk_num, batch_num = _blkinfo(A, d)
    nlen = blk_len * n * batch_num
    cpy = similar(A, nlen)
    batch_len = blk_len * blk_num
    sbatch_len = blk_len * min(n, blk_num)
    δ = 0
    for j in 1:batch_num
        soffs = batch_len * (j - 1) + 1
        doffs = soffs + δ
        copyto!(cpy, doffs, parent(A), soffs, sbatch_len)
        δ = δ + blk_len * (n - blk_num)
    end
    resize!(parent(A), nlen)
    setsize!(A, d, n)
    copyto!(parent(A), cpy)
    return A
end
function resize_buffer_dim!(A::AbstractArray, d::Int, I::Base.LogicalIndex)
    @boundscheck check_dimbounds(A, d, I)
    I′ = I.mask
    n = I.sum
    blk_len, blk_num, batch_num = _blkinfo(A, d)
    nlen = blk_len * n * batch_num
    cpy = similar(A, nlen)
    batch_len = blk_len * blk_num
    δ = 0
    for j in 1:batch_num
        for (k, flag) in enumerate(I′)
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
    setsize!(A, d, n)
    copyto!(parent(A), cpy)
    return A
end
function resize_buffer_dim!(A::AbstractArray, d::Int, I::AbstractVector)
    @boundscheck check_dimbounds(A, d, I)
    I′ = zeros(Bool, size(A, d))
    I′[I] .= true
    n = length(I)
    blk_len, blk_num, batch_num = _blkinfo(A, d)
    nlen = blk_len * n * batch_num
    cpy = similar(A, nlen)
    batch_len = blk_len * blk_num
    δ = 0
    for j in 1:batch_num
        for (k, flag) in enumerate(I′)
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
    setsize!(A, d, n)
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

_to_indices(::AbstractArray, dims, ::True) = dims
_to_indices(A::AbstractArray, dims, ::False) = to_indices(A, dims)

_to_size(inds::Tuple) = map(_to_size, inds)
_to_size(ind) = length(ind)
_to_size(ind::Integer) = Int(ind)

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

# checkbounds at dim d
check_dimbounds(A::AbstractArray, d::Integer, I) =
    checkindex(Bool, axes(A, d), I) || throw_dimboundserror(A, d, I)

setindex(A::NTuple{N,Any}, v, i::Int) where {N} = ntuple(j -> ifelse(j == i, v, A[j]), Val(N))

# Exceptions
struct MethodUndefindeError <: Exception
    f::Any
    T::DataType
end
Base.showerror(io::IO, err::MethodUndefindeError) =
    print(io, "MethodUndefindeError: ", err.f, " is not defined for ", err.T)

throw_methoderror(f, A::AbstractArray{N}) where {N} =
    throw(MethodUndefindeError(f, typeof(A)))

struct DimBoundsError <: Exception
    A::AbstractArray
    d::Int
    I::Any
end
function Base.showerror(io::IO, err::DimBoundsError)
    print(io, "DimBoundsError: attempt to access ")
    summary(io, err.A),
    print(io, " at dimension ", err.d, " with index ")
    if err.I isa Base.LogicalIndex
        print(io, err.I.mask)
    else
        print(io, err.I)
    end
    return nothing
end
throw_dimboundserror(A::AbstractArray{N}, d::Integer, I) where {N} =
    throw(DimBoundsError(A, Int(d), I))