@testset "size(A, i)" begin
    tV = SimpleRDArray(V)
    @test_throws BoundsError size(tV, 0)
    @test size(tV, 0x1) == 3
    @test size(tV, 0x2) == 1
end

@testset "non-resizable arrays" begin
    @test_throws MethodUndefineError sizehint!(1:2, 3)
    @test_throws MethodUndefineError resize!(1:2, (3,))
    @test_throws MethodUndefineError resize!(1:2, 3, 1)
end

@testset "wrong index" begin
    tV = SimpleRDArray(V)
    @test_throws DimBoundsError resize!(tV, 1, Bool[0, 0, 1, 0])
    @test_throws DimBoundsError resize!(tV, 2, Bool[0, 0, 1, 0])
    @test_throws DimBoundsError resize!(tV, 1, 3:4)
    @test_throws DimBoundsError resize!(tV, 2, 1:2)
end

@testset "tailn" begin
    @test tailn(Val(1), 1, 2, 3, 4) == (4,)
    @test tailn(Val(2), 1, 2, 3, 4) == (3, 4)
    @test tailn(Val(3), 1, 2, 3, 4) == (2, 3, 4)
    @test tailn(Val(4), 1, 2, 3, 4) == (1, 2, 3, 4)
    @test tailn(Val(5), 1, 2, 3, 4) == (1, 2, 3, 4)
end

@testset "Size" begin
    tp = ntuple(UInt, Val(4))
    sz = Size(4, 4, 4, 4)
    @test length(sz) == 4
    set!(sz, tp)
    @test sz == tp
end