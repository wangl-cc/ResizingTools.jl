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

@testset "resize!(A, sz)" begin
    @testset "Vector: ($i,)" for i in dims
        RV = SimpleRDArray(V)
        resize!(RV, (i,))
        i isa Colon && (i = 3)
        @test RV[1:min(i, 3)] == V[1:min(i, 3)]
        @test size(RV) == (i,)
    end

    @testset "Matrix: ($i, $j)" for i in dims, j in dims
        RM = SimpleRDArray(M)
        resize!(RM, (i, j))
        i isa Colon && (i = 3)
        j isa Colon && (j = 3)
        @test RM[1:min(i, 3), 1:min(j, 3)] == M[1:min(i, 3), 1:min(j, 3)]
        @test size(RM) == (i, j)
    end

    @testset "3-rank Array: ($i, $j, $k)" for i in dims, j in dims, k in dims
        RT = SimpleRDArray(T)
        resize!(RT, (i, j, k))
        i isa Colon && (i = 3)
        j isa Colon && (j = 3)
        k isa Colon && (k = 3)
        @test RT[1:min(i, 3), 1:min(j, 3), 1:min(k, 3)] ==
              T[1:min(i, 3), 1:min(j, 3), 1:min(k, 3)]
        @test size(RT) == (i, j, k)
    end
end

@testset "resize!(A, d, i)" begin
    @testset "Vector: $d" for d in (2, 3, 4)
        RV = SimpleRDArray(V)
        resize!(RV, d, 1)
        @test RV[1:min(d, 3)] == V[1:min(d, 3)]
        @test size(RV, 1) == d
    end
    @testset "Matrix: $d, $i" for d in (2, 3, 4), i in (1, 2)
        RM = SimpleRDArray(M)
        resize!(RM, d, i)
        inds = [1:3, 1:3]
        inds[i] = 1:min(d, 3)
        @test RM[inds...] == M[inds...]
        @test size(RM, i) == d
    end
    @testset "3-rank Array: $d, $i" for d in (2, 3, 4), i in (1, 2)
        RT = SimpleRDArray(T)
        resize!(RT, d, i)
        inds = [1:3, 1:3, 1:3]
        inds[i] = 1:min(d, 3)
        @test RT[inds...] == T[inds...]
        @test size(RT, i) == d
    end
end

@testset "sizehit!" begin
    @testset "Vector" begin
        @test begin
            RV = SimpleRDArray(V)
            @allocated resize!(RV, (4,))
        end > begin
            RV = SimpleRDArray(V)
            sizehint!(RV, (4,))
            @allocated resize!(RV, (4,))
        end
        @test begin
            RV = SimpleRDArray(V)
            sizehint!(parent(RV), 4)
            @allocated resize!(RV, (4,))
        end == begin
            RV = SimpleRDArray(V)
            sizehint!(RV, (4,))
            @allocated resize!(RV, (4,))
        end
    end
    @testset "Matrix" begin
        @test begin
            RM = SimpleRDArray(M)
            @allocated resize!(RM, (4, 4))
        end > begin
            RM = SimpleRDArray(M)
            sizehint!(RM, (4, 4))
            @allocated resize!(RM, (4, 4))
        end
        @test begin
            RM = SimpleRDArray(M)
            sizehint!(parent(RM), 16)
            @allocated resize!(RM, (4, 4))
        end == begin
            RM = SimpleRDArray(M)
            sizehint!(RM, (4, 4))
            @allocated resize!(RM, (4, 4))
        end
    end
    @testset "3-rank array" begin
        @test begin
            RT = SimpleRDArray(T)
            @allocated resize!(RT, (4, 4, 4))
        end > begin
            RT = SimpleRDArray(T)
            sizehint!(RT, (4, 4, 4))
            @allocated resize!(RT, (4, 4, 4))
        end
        @test begin
            RT = SimpleRDArray(T)
            sizehint!(parent(RT), 64)
            @allocated resize!(RT, (4, 4, 4))
        end == begin
            RT = SimpleRDArray(T)
            sizehint!(RT, (4, 4, 4))
            @allocated resize!(RT, (4, 4, 4))
        end
    end
end
