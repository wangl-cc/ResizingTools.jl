const Dim = Union{Int,Base.Slice}

"""
    BufferType = Union{Vector,BitVector}

Types which can be a buffer.
"""
const BufferType = Union{Vector,BitVector}

"""
    isresizable(A::AbstractArray)

Determines if an array is resizable, if not `resize!(A, args...)` would throw an error.
"""
isresizable(A::AbstractArray) = isresizable(typeof(A))
isresizable(::Type{T}) where {T} = _isresizable(has_parent(T), parent_type(T))
_isresizable(::True, ::Type{T}) where {T} = isresizable(T)
_isresizable(::True, ::Type{<:BufferType}) = true
_isresizable(::False, ::Type) = false
_isresizable(::False, ::Type{<:BufferType}) = true # BufferType is resizable now

"""
    has_resize_buffer(A::AbstractArray)

Determines if an array has `resize_buffer*` methods,
if not `resize!(A, args...)` would resize its parent.
"""
has_resize_buffer(A::AbstractArray) = has_resize_buffer(typeof(A))
has_resize_buffer(::Type{T}) where {T} = parent_type(T) <: BufferType

"""
    to_parentinds(A::AbstractArray, Is::Tuple) -> Is′

Convert the index(s) `Is` of `A` to index(s) `Is′` of `parent(A)`.
"""
to_parentinds(::AbstractArray, Is::Tuple) = Is
"""
    to_parentinds(A::AbstractArray, i::Integer, I) -> (i′, I′)

Convert the index(s) `I` at `d`th dimension of `A` to index(s) `I′` at `d′`th
dimension of `parent(A)`.
"""
to_parentinds(::AbstractArray, d::Integer, I) = d, I
# impl of adjoint and transpose
to_parentinds(A::AdjOrTransAbsVec, (i, J)::Tuple) = (check_dimbounds(A, 1, i); (J,))
to_parentinds(::AdjOrTransAbsMat, (I, J)::Tuple) = (J, I)
to_parentinds(::AdjOrTrans, d::Integer, I) = ifelse(d == 1, 2, 1), I

"""
    copyto_parent!(dst::AbstractArray, src::AbstractArray, dinds...)

Copy the elements of `src` to parent of `dst` at the `dst` indices `dinds`.
This method is called by `resize_buffer!` to copy elements of the parent.
The default method is `copyto!(view(dst, dinds...), src)`.
The default method assumes that
`setindex!(parent(dst), v, i...)` is the same as `setindex!(dst, v, i...)` .
Override this method if they are different.
"""
copyto_parent!(dst::AbstractArray, src::AbstractArray, dinds...) =
    copyto!(view(dst, dinds...), src)

# Base.sizehint!(A, sz)
"""
    sizehint!(A::AbstractArray{T,N}, sz::NTuple{N}) where {T,N}

Suggest that array `A` reserve size for at least `sz`.
This can improve performance.
"""
Base.sizehint!(A::AbstractArray{T,N}, sz::NTuple{N,Any}) where {T,N} =
    sizehint!(A, to_dims(sz))
Base.sizehint!(A::AbstractArray{T,N}, sz::Dims{N}) where {T,N} = sizehint!(A, prod(sz))

"""
    Base.sizehint!(A::AbstractArray, nl::Integer)

Suggest that array `A` reserve capacity for at least `nl` elements.
This can improve performance.
"""
function Base.sizehint!(A::AbstractArray, nl::Integer)
    if isresizable(A)
        sizehint!(parent(A), nl)
        return A
    end
    throw_methoderror(sizehint!, A)
end

"""
    resize_parent!(A::AbstractArray{T,N}, sz::NTuple{N})

The same as `resize_parent!(A, prod(sz)`.
"""
@inline resize_parent!(A::AbstractArray{T,N}, sz::NTuple{N,Any}) where {T,N} =
    resize_parent!(A, prod(to_dims(sz)))

"""
    resize_parent!(A::AbstractArray, nl::Integer)

Resize the parent of A. This method will (and should only) be called by
`resize_buffer!` or `resize_buffer_dim!`, the default implementation is
`resize!(parent(A), nl)`, but for arrays with preserved space, this methods can
be override to keep size of parent.
"""
resize_parent!(A::AbstractArray, nl::Integer) = resize_parent!(A, Int(nl))
function resize_parent!(A::AbstractArray, nl::Int)
    if parent_type(A) <: BufferType
        return resize!(parent(A), nl)
    end
    error("parent_type(A) must be BufferType")
end

"""
    pre_resize!(A::AbstractArray{T,N}, sz::NTuple{N,Any})
    pre_resize!(A::AbstractArray{T,N}, d::Integer, n::Any)

Do something before resize `A` with given arguments (do nothing by default).
This method is called by `resize!` with the same arguments.
"""
pre_resize!
"""
    after_resize!(A::AbstractArray{T,N}, sz::NTuple{N,Any})
    after_resize!(A::AbstractArray{T,N}, d::Integer, n::Any)

Do something after resize `A` with given arguments (do nothing by default).
This methods is called by `resize!` with the same arguments.
"""
after_resize!

@inline pre_resize!(A::AbstractArray{T,N}, ::NTuple{N,Any}) where {T,N} = A
@inline after_resize!(A::AbstractArray{T,N}, ::NTuple{N,Any}) where {T,N} = A

"""
    resize!(A::AbstractArray{T,N}, sz)

Resize `A` to `sz`. `sz` can be a tuple of integer or Colon or iterator.
"""
function Base.resize!(A::AbstractArray{T,N}, dims::NTuple{N,Any}, ::B=False()) where {T,N,B}
    if isresizable(A)
        dims′ = _to_indices(A, dims, B())
        pre_resize!(A, dims′)
        if has_resize_buffer(A)
            resize_buffer!(A, to_indices(A, dims′)...)
        else
            resize!(parent(A), to_parentinds(A, dims′), True())
            setsize!(A, dims′)
        end
        after_resize!(A, dims′)
        return A
    end
    throw_methoderror(resize!, A)
end

"""
    resize_buffer!(A::AbstractArray, nsz...)

Implementation of `resize!(A, nsz)` where `parent(A)` is [`BufferType`](@ref).
"""
resize_buffer!(A::AbstractArray, nsz...) = _resize_buffer!(A, nsz...)
# resize vector will not move any element
function _resize_buffer!(A::AbstractVector{T}, n::Int) where {T}
    checksize(A, (n,))
    resize_parent!(A, n) # resize! buffer by Base.resize!
    setsize!(A, 1, n)
    return A
end
# resize array with Int sz
function _resize_buffer!(A::AbstractArray{T,N}, nsz::Vararg{Int,N}) where {T,N}
    checksize(A, nsz)
    sz = size(A)
    nsz == sz && return A # if sz not change
    if nsz[1:N-1] == sz[1:N-1] # if only last dim changed
        resize_parent!(A, nsz)
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
    resize_parent!(A, nsz)
    setsize!(A, nsz)
    # step 3: copy src to dst region of A
    copyto_parent!(A, src, map(Base.OneTo, ssz)...)
    return A
end
# resize with Colon
function _resize_buffer!(A::AbstractArray{T,N}, dims::Vararg{Dim,N}) where {T,N}
    M = restdim(Base.Slice, dims...)
    # if only last dim changed
    if M == 1
        dims[N] > 0 || error("dimension(s) must be > 0")
        nlen = stride(A, N) * dims[N]
        resize_parent!(A, nlen)
        setsize!(A, N, dims[N])
        return A
    end
    nsz = to_dims(dims)
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
    resize_parent!(A, nlen)
    setsize!(A, dims)
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
_resize_buffer!(A::AbstractArray{T,N}, ::Vararg{Base.Slice,N}) where {T,N} = A
# resize with inds
function _resize_buffer!(A::AbstractArray{T,N}, inds::Vararg{Any,N}) where {T,N}
    sz = to_dims(inds)
    nlen = prod(sz)
    sinds = map(_to_sind, axes(A), inds)
    src = A[sinds...]
    resize_parent!(A, nlen)
    setsize!(A, inds)
    dinds = map(_to_oneto, sinds)
    copyto_parent!(A, src, dinds...)
    return A
end

_to_sind(ind, n::Integer) = n >= length(ind) ? UnitRange(ind) : UnitRange(ind[1:n])
_to_sind(ind, I) = I
_to_oneto(I) = Base.OneTo(length(I))

@inline pre_resize!(A::AbstractArray, ::Int, ::Any) = A
@inline after_resize!(A::AbstractArray, ::Int, ::Any) = A

"""
    resize!(A::AbstractArray{T,N}, d::Integer, I)

Resize the `d`th dimension to `I`, where `I` can be an integer or a colon or an iterator.
"""
function Base.resize!(A::AbstractArray, d::Integer, I)
    if isresizable(A)
        d′ = Int(d)
        I′ = Base.to_index(I)
        pre_resize!(A, d′, I′)
        if has_resize_buffer(A)
            resize_buffer_dim!(A, d′, I′)
        else
            resize!(parent(A), to_parentinds(A, d′, I′)...)
            setsize!(A, d′, I′)
        end
        after_resize!(A, d′, I′)
        return A
    end
    throw_methoderror(resize!, A)
end
Base.resize!(A::AbstractArray, ::Integer, ::Colon) = A

"""
    resize_buffer_dim!(A::AbstractArray, d::Int, I)

Implementation of `resize!(A, d, I)` where `parent(A)` is a [`BufferType`](@ref).
"""
resize_buffer_dim!(A::AbstractArray, d::Int, I) = _resize_buffer_dim!(A, d, I)

function _resize_buffer_dim!(A::AbstractArray, d::Int, n::Int)
    N = ndims(A)
    n == size(A, d) && return A
    if d == N
        resize_parent!(A, stride(A, N) * n)
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
    resize_parent!(A, nlen)
    setsize!(A, d, n)
    copyto!(parent(A), cpy)
    return A
end
function _resize_buffer_dim!(A::AbstractArray, d::Int, I::Base.LogicalIndex)
    @boundscheck check_dimbounds(A, d, I)
    I′ = I.mask
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
    resize_parent!(A, nlen)
    setsize!(A, d, I)
    copyto!(parent(A), cpy)
    return A
end
function _resize_buffer_dim!(A::AbstractArray, d::Int, I::AbstractVector)
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
    resize_parent!(A, nlen)
    setsize!(A, d, I)
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

@inline _to_indices(::AbstractArray, dims, ::True) = dims
@inline _to_indices(A::AbstractArray, dims, ::False) = to_indices(A, dims)

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

# Exceptions
struct MethodUndefineError <: Exception
    f::Any
    T::DataType
end
Base.showerror(io::IO, err::MethodUndefineError) =
    print(io, "MethodUndefineError: ", err.f, " is not defined for ", err.T)

throw_methoderror(f, A::AbstractArray{N}) where {N} =
    throw(MethodUndefineError(f, typeof(A)))

struct DimBoundsError <: Exception
    A::AbstractArray
    d::Int
    I::Any
end
function Base.showerror(io::IO, err::DimBoundsError)
    print(io, "DimBoundsError: attempt to access ")
    summary(io, err.A), print(io, " at dimension ", err.d, " with index ")
    if err.I isa Base.LogicalIndex
        print(io, err.I.mask)
    else
        print(io, err.I)
    end
    return nothing
end
throw_dimboundserror(A::AbstractArray{N}, d::Integer, I) where {N} =
    throw(DimBoundsError(A, Int(d), I))
