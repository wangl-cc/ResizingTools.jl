using Test
using ArrayInterface
using ResizingTools
using ResizingTools: setindex
using Aqua

const V = rand(3)
const M = rand(3, 3)
const T = rand(3, 3, 3)

const DIMS = (:, 2, 3, 4)
const ITRS = (
    1:1,
    1:2,
    1:3,
    [true, true, true],
    [false, true, true],
    [true, false, true],
    [true, true, false],
    [false, false, true],
    [false, true, false],
    [true, false, false],
    # [false, false, false],
)

_tolen(itr) = eltype(itr) <: Bool ? sum(itr) : length(itr)
_params(T::UnionAll) = _params(T.body)
_params(T::DataType) = T.parameters

@testset "ResizingTools" begin
    @testset "QA" begin
        @testset "Ambiguity" begin
            ambiguities = Test.detect_ambiguities(ResizingTools)
            filter!(ambiguities) do (m1, m2)
                p1 = _params(m1.sig)
                p2 = _params(m2.sig)
                for (t1, t2) in zip(p1, p2)
                    typeintersect(t1, t2) === Union{} && return false
                end
                return true
            end
            @test length(ambiguities) == 0
        end
        Aqua.test_all(ResizingTools; ambiguities=false)
    end

    @testset "arraymath" begin
        include("arraymath.jl")
    end
    @testset "SimpleRDArray" begin
        include("simplerdarray.jl")
    end
    @testset "WarpedArray" begin
        include("warpedarray.jl")
    end
    @testset "AdjoinOrTranspose" begin
        include("adjortrans.jl")
    end
end
