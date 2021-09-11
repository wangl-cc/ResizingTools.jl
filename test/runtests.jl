using ResizingTools
using Test

const V = rand(3)
const M = rand(3, 3)
const T = rand(3, 3, 3)

const dims = (:, 2, 3, 4)

@testset "math" begin
    RV = SimpleRDArray(V)
    RM = SimpleRDArray(M)
    @test RV == V
    @test RM == M
    @test M * V == RM * V == M * RV == RM * RV
    @test M * M == M * RM == RM * M == RM * RM
end

@testset "resize!" begin
    @testset "Vector: ($i,)" for i in dims
        RV = SimpleRDArray(V)
        resize!(RV, i)
        i isa Colon && (i = 3)
        @test RV[1:min(i, 3)] == V[1:min(i, 3)]
        @test size(RV) == (i,)
    end

    @testset "Matrix: ($i, $j)" for i in dims, j in dims
        RM = SimpleRDArray(M)
        resize!(RM, i, j)
        i isa Colon && (i = 3)
        j isa Colon && (j = 3)
        @test RM[1:min(i, 3), 1:min(j, 3)] == M[1:min(i, 3), 1:min(j, 3)]
        @test size(RM) == (i, j)
    end

    @testset "3-rank Array: ($i, $j, $k)" for i in dims, j in dims, k in dims
        RT = SimpleRDArray(T)
        resize!(RT, i, j, k)
        i isa Colon && (i = 3)
        j isa Colon && (j = 3)
        k isa Colon && (k = 3)
        @test RT[1:min(i, 3), 1:min(j, 3), 1:min(k, 3)] ==
              T[1:min(i, 3), 1:min(j, 3), 1:min(k, 3)]
        @test size(RT) == (i, j, k)
    end
end
