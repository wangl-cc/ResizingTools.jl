@testset "size(A, i)" begin
    tV = SimpleRDArray(V)
    @test_throws BoundsError size(tV, 0)
    @test size(tV, 0x1) == 3
    @test size(tV, 0x2) == 1
end

@testset "unresizable arrays" begin
    @test_throws MethodUndefindeError sizehint!(1:2, 3)
    @test_throws MethodUndefindeError resize!(1:2, (3,))
    @test_throws MethodUndefindeError resize!(1:2, 3, 1)
end

@testset "tailn" begin
    @test tailn(Val(1), 1, 2, 3, 4) == (4,)
    @test tailn(Val(2), 1, 2, 3, 4) == (3, 4)
    @test tailn(Val(3), 1, 2, 3, 4) == (2, 3, 4)
    @test tailn(Val(4), 1, 2, 3, 4) == (1, 2, 3, 4)
    @test tailn(Val(5), 1, 2, 3, 4) == (1, 2, 3, 4)
end