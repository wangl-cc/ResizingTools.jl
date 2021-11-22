const DIMS = (:, 0x2, 3, 4)
const ITRS = (
    DIMS...,
    1:1,
    1:2,
    1:3,
    [true, true, true],
    not(1),
    FI(iseven),
    [false, true, true],
    [true, false, true],
    [true, true, false],
    [false, false, true],
    [false, true, false],
    [true, false, false],
    # [false, false, false],
)

struct WarpedArray{T,N,P} <: ResizingTools.AbstractRDArray{T,N}
    parent::P
    WarpedArray(A::P) where {T,N,P<:AbstractArray{T,N}} = new{T,N,P}(A)
end
warpsimplerdarray(A::AbstractArray) = WarpedArray(SimpleRDArray(A))

Base.parent(A::WarpedArray) = A.parent
ArrayInterface.parent_type(::Type{<:WarpedArray{T,N,P}}) where {T,N,P} = P
Base.IndexStyle(::Type{A}) where {A<:WarpedArray} =
    IndexStyle(ArrayInterface.parent_type(A))
Base.@propagate_inbounds Base.getindex(A::WarpedArray, Is...) = parent(A)[Is...]
Base.@propagate_inbounds Base.setindex!(A::WarpedArray, v, Is...) = parent(A)[Is...] = v
ResizingTools.getsize(A::WarpedArray) = ResizingTools.getsize(parent(A))
ResizingTools.getsize(A::WarpedArray, d::Int) = ResizingTools.getsize(parent(A), d)

_geninds(A::AbstractArray, d::Integer, I) =
    ntuple(i -> i == d ? _to_inds(A, d, I) : axes(A, i), Val(ndims(A)))
_geninds(A::AbstractArray, Is::Tuple) = ntuple(i -> _to_inds(A, i, Is[i]), Val(ndims(A)))

_to_inds(A::AbstractArray, d::Integer, itr) = ResizingTools.to_index(A, axes(A, d), itr)
_to_inds(A::AbstractArray, d::Integer, ::Colon) = axes(A, d)
_to_inds(A::AbstractArray, d::Integer, n::Integer) = Base.OneTo(min(n, size(A, d)))

_to_sinds(inds) = map(ind -> Base.OneTo(length(ind)), inds)

_to_size(A::AbstractArray, Is::Tuple) = ntuple(i -> _to_len(A, i, Is[i]), Val(ndims(A)))
_to_len(::AbstractArray, ::Integer, itr) = eltype(itr) <: Bool ? sum(itr) : length(itr)
_to_len(A::AbstractArray, d::Integer, I::FunctionIndices.AbstractFunctionIndex) =
    length(_to_inds(A, d, I))
_to_len(::AbstractArray, ::Integer, n::Integer) = n
_to_len(A::AbstractArray, d::Integer, ::Colon) = size(A, d)

struct NLoop{N,T} <: AbstractArray{Any,N}
    itr::T
end
NLoop{N}(tp::Tuple) where {N} = NLoop{N,typeof(tp)}(tp)
Base.IndexStyle(::Type{<:NLoop}) = IndexCartesian()
Base.size(A::NLoop{N}) where {N} = ntuple(_ -> length(A.itr), Val(N))
Base.getindex(A::NLoop{N}, is::Vararg{Int,N}) where {N} = ntuple(i -> A.itr[is[i]], Val(N))

function test_resize(f, g, A::AbstractArray{T,N}, itrs, dnums=1:N; pre=identity) where {T,N}
    @testset "resize!($(typeof(A)), $_Is)" for _Is in NLoop{N}(itrs)
        Is = pre(_Is)
        tA = g(f(A))
        fA = f(A)
        resize!(tA, Is)
        inds = _geninds(fA, Is)
        @test tA[_to_sinds(inds)...] == fA[inds...]
        @test size(tA) == _to_size(fA, Is)
    end
    @testset "resize!($(typeof(A)), $d, $I)" for d in dnums, I in itrs
        tA = g(f(A))
        fA = f(A)
        resize!(tA, d, I)
        inds = _geninds(fA, d, I)
        @test tA[_to_sinds(inds)...] == fA[inds...]
        @test size(tA, d) == _to_len(fA, d, I)
    end
end
test_resize(g, A::AbstractArray{T,N}, itrs, dnums=1:N; pre=identity) where {T,N} =
    test_resize(identity, g, A, itrs, dnums; pre=pre)

@testset "resize!: $f" for f in (SimpleRDArray, warpsimplerdarray)
    for A in (V, M, T)
        test_resize(f, A, ITRS)
    end
end

adjIS(I) = length(I) == 1 ? (1, I[1]) : I
@testset "resize!: adjoint" begin
    test_resize(adjoint, SimpleRDArray, V, ITRS, 2; pre=adjIS)
    test_resize(adjoint, SimpleRDArray, M, ITRS)
end

@testset "sizehint!: $f" for f in (SimpleRDArray, warpsimplerdarray)
    @testset "Vector" begin
        @test begin
            tV = f(V)
            @allocated resize!(tV, (4,))
        end > begin
            tV = f(V)
            sizehint!(tV, (4,))
            @allocated resize!(tV, (4,))
        end
        @test begin
            tV = f(V)
            sizehint!(parent(tV), 4)
            @allocated resize!(tV, (4,))
        end == begin
            tV = f(V)
            sizehint!(tV, (4,))
            @allocated resize!(tV, (4,))
        end
    end
    @testset "Matrix" begin
        @test begin
            tM = f(M)
            @allocated resize!(tM, (4, 4))
        end > begin
            tM = f(M)
            sizehint!(tM, (4, 4))
            @allocated resize!(tM, (4, 4))
        end
        @test begin
            tM = f(M)
            sizehint!(parent(tM), 16)
            @allocated resize!(tM, (4, 4))
        end == begin
            tM = f(M)
            sizehint!(tM, (4, 4))
            @allocated resize!(tM, (4, 4))
        end
    end
    @testset "3-rank array" begin
        @test begin
            tT = f(T)
            @allocated resize!(tT, (4, 4, 4))
        end > begin
            tT = f(T)
            sizehint!(tT, (4, 4, 4))
            @allocated resize!(tT, (4, 4, 4))
        end
        @test begin
            tT = f(T)
            sizehint!(parent(tT), 64)
            @allocated resize!(tT, (4, 4, 4))
        end == begin
            tT = f(T)
            sizehint!(tT, (4, 4, 4))
            @allocated resize!(tT, (4, 4, 4))
        end
    end
end

@testset "resize! with both Integer and AbstractArray #4" begin
    tM = SimpleRDArray(reshape(1:4, 2, 2))
    @test resize!(tM, (2, 1:2)) == reshape(1:4, 2, 2)
    @test resize!(tM, (1:2, 1)) == reshape(1:2, 2, 1)
end

@testset "resize!(::Vector, ::Any)" begin
    @test resize!(collect(1:4), (3,)) == 1:3
    @test resize!(collect(1:4), (5,))[1:4] == 1:4
    @test resize!(collect(1:4), (:,)) == 1:4
    @test resize!(collect(1:4), (1:3,)) == 1:3
    @test resize!(collect(1:4), (Bool[1, 0, 1, 1],)) == [1, 3, 4]
end
