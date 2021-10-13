# ResizingTools.jl

[![Build Status](https://github.com/wangl-cc/ResizingTools.jl/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/wangl-cc/ResizingTools.jl/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/wangl-cc/ResizingTools.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/wangl-cc/ResizingTools.jl)
[![GitHub](https://img.shields.io/github/license/wangl-cc/ResizingTools.jl)](https://github.com/wangl-cc/ResizingTools.jl/blob/master/LICENSE)
[![Docs dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://wangl-cc.github.io/ResizingTools.jl/dev/)
[![Docs stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://wangl-cc.github.io/ResizingTools.jl/stable/)

`ResizingTools` helps you create resizable `Array` types.

## Get started with `SimpleRDArray`

`SimpleRDArray` is a simple implementation of the resizable dense array, which
can be created simply:

```julia
julia> M = reshape(1:9, 3, 3)
3×3 reshape(::UnitRange{Int64}, 3, 3) with eltype Int64:
 1  4  7
 2  5  8
 3  6  9

julia> RM = SimpleRDArray(M)
3×3 SimpleRDArray{Int64, 2}:
 1  4  7
 2  5  8
 3  6  9

julia> M == RM
true
```

Once a `SimpleRDArray` is created, you can almost do anything with which likes a
normal `Array` with similar performance:

```julia
julia> @benchmark $RM * $RM
BenchmarkTools.Trial: 10000 samples with 980 evaluations.
 Range (min … max):   77.283 ns … 26.663 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     214.530 ns              ┊ GC (median):    0.00%
 Time  (mean ± σ):   300.628 ns ±  1.292 μs  ┊ GC (mean ± σ):  6.87% ± 5.58%

      █▂                                                        
  ▁▁▁▆██▄▂▁▁▁▁▁▁▁▁▂▂▂▃▃▃▃▃▄▄▄▄▄▄▄▄▃▃▃▃▃▃▂▂▂▂▂▂▂▂▂▂▁▁▁▁▁▁▁▁▁▁▁▁ ▂
  77.3 ns         Histogram: frequency by time          430 ns <

 Memory estimate: 160 bytes, allocs estimate: 1.

julia> @benchmark $M * $M
BenchmarkTools.Trial: 10000 samples with 980 evaluations.
 Range (min … max):   71.658 ns …   4.237 μs  ┊ GC (min … max): 0.00% … 94.53%
 Time  (median):     144.504 ns               ┊ GC (median):    0.00%
 Time  (mean ± σ):   161.228 ns ± 206.767 ns  ┊ GC (mean ± σ):  7.40% ±  5.60%

              ▁▅▇█▇▅▂                                            
  ▂▁▂▂▂▂▂▂▃▄▅▆███████▇▄▃▃▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ▃
  71.7 ns          Histogram: frequency by time          356 ns <
 Memory estimate: 160 bytes, allocs estimate: 1.

julia> RM * RM == M * M
true
```

Besides, a `SimpleRDArray` can be resized in many ways:

```julia
julia> resize!(RM, (4, 4)) # resize RM to 4 * 4
4×4 SimpleRDArray{Int64, 2}:
 1  4   7   81
 2  5   8   96
 3  6   9  102
 4  8  66  126

julia> RM[1:3,1:3] == M
true
julia> resize!(RM, 2, 3) # resize the 2nd dimension of RM to 3
4×3 SimpleRDArray{Int64, 2}:
 1  4   7
 2  5   8
 3  6   9
 4  8  66

julia> RM[4, :] .= 0
3-element view(::SimpleRDArray{Int64, 2}, 4, :) with eltype Int64:
 0
 0
 0

julia> resize!(RM, 1, Bool[1, 1, 0, 1]) # delete RM[3, :]
3×3 SimpleRDArray{Int64, 2}:
 1  4  7
 2  5  8
 0  0  0
```

## Make your own array resizable

To make your own resizable array, you only need is defined some interface
methods, see
[docs](https://wangl-cc.github.io/ResizingTools.jl/dev/manual/#Interfaces) for
details.
