using Test
using ArrayInterface
using ResizingTools
using ResizingTools: MethodUndefindeError, DimBoundsError,tailn
using Aqua

const V = rand(3)
const M = rand(3, 3)
const T = rand(3, 3, 3)

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
    @testset "resize" begin
        include("resize.jl")
    end
    @testset "MISC" begin
        include("misc.jl")
    end
end
