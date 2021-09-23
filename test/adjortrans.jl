const adjV = V'
const adjM = M'

adjsimple(A) = adjoint(SimpleRDArray(A))

@testset "resize!(A, sz)" begin
    @testset "AdjVec: ($i,)" for i in DIMS
        tV = adjsimple(V)
        resize!(tV, (1, i))
        i isa Colon && (i = 3)
        @test tV[1, 1:min(i, 3)] == adjV[1, 1:min(i, 3)]
        @test size(tV) == (1, i)
    end
    @testset "AdjMat: ($i, $j)" for i in DIMS, j in DIMS
        tM = adjsimple(M)
        resize!(tM, (i, j))
        i isa Colon && (i = 3)
        j isa Colon && (j = 3)
        @test tM[1:min(i, 3), 1:min(j, 3)] == adjM[1:min(i, 3), 1:min(j, 3)]
        @test size(tM) == (i, j)
    end
end

@testset "resize!(A, itr)" begin
    @testset "AdjVec: ($i,)" for i in ITRS
        tV = adjsimple(V)
        resize!(tV, (1, i))
        @test tV[1, :] == adjV[1, i]
        @test size(tV) == (1, _tolen(i))
    end
    @testset "AdjMat: ($i, $j)" for i in ITRS, j in ITRS
        tM = adjsimple(M)
        resize!(tM, (i, j))
        @test tM == adjM[i, j]
        @test size(tM) == (_tolen(i), _tolen(j))
    end
end

@testset "resize!(A, d, i)" begin
    @testset "AdjVec: $d" for d in (2, 3, 4)
        tV = adjsimple(V)
        resize!(tV, d, 2)
        @test tV[1, 1:min(d, 3)] == adjV[1, 1:min(d, 3)]
        @test size(tV, 2) == d
    end
    @testset "AdjMat: $d, $i" for d in (2, 3, 4), i in (1, 2)
        tM = adjsimple(M)
        resize!(tM, d, i)
        inds = [1:3, 1:3]
        inds[i] = 1:min(d, 3)
        @test tM[inds...] == adjM[inds...]
        @test size(tM, i) == d
    end
end
