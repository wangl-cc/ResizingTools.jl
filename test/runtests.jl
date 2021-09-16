using Test
using ArrayInterface
using ResizingTools
using ResizingTools: setindex

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

@testset "ResizingTools" begin
    @testset "arraymath" begin
        include("arraymath.jl")
    end
    @testset "SimpleRDArray" begin
        include("simplerdarray.jl")
    end
    @testset "WarpedArray" begin
        include("warpedarray.jl")
    end
end