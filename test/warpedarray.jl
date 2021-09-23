struct WarpedArray{T,N,P} <: ResizingTools.AbstractRDArray{T,N}
    parent::P
    WarpedArray(A::P) where {T,N,P<:AbstractArray{T,N}} = new{T,N,P}(A)
end

Base.parent(A::WarpedArray) = A.parent
ArrayInterface.parent_type(::Type{<:WarpedArray{T,N,P}}) where {T,N,P} = P
ResizingTools.getsize(A::WarpedArray) = ResizingTools.getsize(parent(A))
ResizingTools.getsize(A::WarpedArray, d::Int) = ResizingTools.getsize(parent(A), d)
ResizingTools.setsize!(::WarpedArray{T,N}, sz::Dims{N}) where {T,N} = sz
ResizingTools.setsize!(::WarpedArray{T,N}, d::Int, ::Int) where {T,N} = d

warpsimplerdarray(A::AbstractArray) = WarpedArray(SimpleRDArray(A))

@testset "resize!(A, sz)" begin
    @testset "Vector: ($i,)" for i in DIMS
        tV = warpsimplerdarray(V)
        resize!(tV, (i,))
        i isa Colon && (i = 3)
        @test tV[1:min(i, 3)] == V[1:min(i, 3)]
        @test size(tV) == (i,)
    end

    @testset "Matrix: ($i, $j)" for i in DIMS, j in DIMS
        tM = warpsimplerdarray(M)
        resize!(tM, (i, j))
        i isa Colon && (i = 3)
        j isa Colon && (j = 3)
        @test tM[1:min(i, 3), 1:min(j, 3)] == M[1:min(i, 3), 1:min(j, 3)]
        @test size(tM) == (i, j)
    end

    @testset "3-rank Array: ($i, $j, $k)" for i in DIMS, j in DIMS, k in DIMS
        tT = warpsimplerdarray(T)
        resize!(tT, (i, j, k))
        i isa Colon && (i = 3)
        j isa Colon && (j = 3)
        k isa Colon && (k = 3)
        @test tT[1:min(i, 3), 1:min(j, 3), 1:min(k, 3)] ==
              T[1:min(i, 3), 1:min(j, 3), 1:min(k, 3)]
        @test size(tT) == (i, j, k)
    end
end
@testset "resize!(A, ind)" begin
    @testset "Vector: ($i,)" for i in ITRS
        tV = warpsimplerdarray(V)
        resize!(tV, (i,))
        @test tV == V[i]
        @test size(tV) == (_tolen(i),)
    end
    @testset "Matrix: ($i, $j)" for i in ITRS, j in ITRS
        tM = warpsimplerdarray(M)
        resize!(tM, (i, j))
        @test tM == M[i, j]
        @test size(tM) == (_tolen(i), _tolen(j))
    end
    @testset "Array: ($i, $j, $k)" for i in ITRS, j in ITRS, k in ITRS
        tT = warpsimplerdarray(T)
        resize!(tT, (i, j, k))
        @test tT == T[i, j, k]
        @test size(tT) == (_tolen(i), _tolen(j), _tolen(k))
    end
end

@testset "resize!(A, d, i)" begin
    @testset "Vector: $d" for d in (2, 3, 4)
        tV = warpsimplerdarray(V)
        resize!(tV, d, 1)
        @test tV[1:min(d, 3)] == V[1:min(d, 3)]
        @test size(tV, 1) == d
    end
    @testset "Matrix: $d, $i" for d in (2, 3, 4), i in (1, 2)
        tM = warpsimplerdarray(M)
        resize!(tM, d, i)
        inds = [1:3, 1:3]
        inds[i] = 1:min(d, 3)
        @test tM[inds...] == M[inds...]
        @test size(tM, i) == d
    end
    @testset "3-rank Array: $d, $i" for d in (2, 3, 4), i in (1, 2, 3)
        tT = warpsimplerdarray(T)
        resize!(tT, d, i)
        inds = [1:3, 1:3, 1:3]
        inds[i] = 1:min(d, 3)
        @test tT[inds...] == T[inds...]
        @test size(tT, i) == d
    end
end

@testset "resize!(A, itr, i)" begin
    @testset "Vector: ($itr)" for itr in ITRS
        tV = warpsimplerdarray(V)
        resize!(tV, itr, 1)
        @test tV == V[itr]
        @test size(tV, 1) == _tolen(itr)
    end
    @testset "Matrix: ($itr, $i)" for itr in ITRS, i in (1, 2)
        tM = warpsimplerdarray(M)
        resize!(tM, itr, i)
        inds = setindex((:, :), itr, i)
        @test tM == M[inds...]
        @test size(tM, i) == _tolen(itr)
    end
    @testset "3-rank Array: ($itr, $i)" for itr in ITRS, i in (1, 2, 3)
        tT = warpsimplerdarray(T)
        resize!(tT, itr, i)
        inds = setindex((:, :, :), itr, i)
        @test tT == T[inds...]
        @test size(tT, i) == _tolen(itr)
    end
end

@testset "sizehit!" begin
    @testset "Vector" begin
        @test begin
            tV = warpsimplerdarray(V)
            @allocated resize!(tV, (4,))
        end > begin
            tV = warpsimplerdarray(V)
            sizehint!(tV, (4,))
            @allocated resize!(tV, (4,))
        end
        @test begin
            tV = warpsimplerdarray(V)
            sizehint!(parent(tV), 4)
            @allocated resize!(tV, (4,))
        end == begin
            tV = warpsimplerdarray(V)
            sizehint!(tV, (4,))
            @allocated resize!(tV, (4,))
        end
    end
    @testset "Matrix" begin
        @test begin
            tM = warpsimplerdarray(M)
            @allocated resize!(tM, (4, 4))
        end > begin
            tM = warpsimplerdarray(M)
            sizehint!(tM, (4, 4))
            @allocated resize!(tM, (4, 4))
        end
        @test begin
            tM = warpsimplerdarray(M)
            sizehint!(parent(tM), 16)
            @allocated resize!(tM, (4, 4))
        end == begin
            tM = warpsimplerdarray(M)
            sizehint!(tM, (4, 4))
            @allocated resize!(tM, (4, 4))
        end
    end
    @testset "3-rank array" begin
        @test begin
            tT = warpsimplerdarray(T)
            @allocated resize!(tT, (4, 4, 4))
        end > begin
            tT = warpsimplerdarray(T)
            sizehint!(tT, (4, 4, 4))
            @allocated resize!(tT, (4, 4, 4))
        end
        @test begin
            tT = warpsimplerdarray(T)
            sizehint!(parent(tT), 64)
            @allocated resize!(tT, (4, 4, 4))
        end == begin
            tT = warpsimplerdarray(T)
            sizehint!(tT, (4, 4, 4))
            @allocated resize!(tT, (4, 4, 4))
        end
    end
end
