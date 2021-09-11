# ResizingTools.jl

`ResizingTools` helps you create a `Array` type, which can be resized at each dimension.

## Quick start with the pre-defined `SimpleRDArray`

`SimpleRDArray` is a simple implementation of resizable dense array.

### Create a `SimpleRDArray`

You can create a `SimpleRDArray` simply:
```julia
julia> M = rand(3, 3) # create a 
3×3 Matrix{Float64}:
 0.00508115  0.139107  0.049149
 0.550149    0.962163  0.27269
 0.00244147  0.627738  0.546366

julia> RM = SimpleRDArray(M)
3×3 SimpleRDArray{Float64, 2}:
 0.00508115  0.139107  0.049149
 0.550149    0.962163  0.27269
 0.00244147  0.627738  0.546366

julia> M == RM
true
```

### Do something for `Arrays`

```julia
julia> RM * RM == M * M # matrix mul
true

julia> @benchmark $RM * $RM
BenchmarkTools.Trial: 10000 samples with 973 evaluations.
 Range (min … max):   70.987 ns …  10.996 μs  ┊ GC (min … max): 0.00% … 98.82%
 Time  (median):     110.323 ns               ┊ GC (median):    0.00%
 Time  (mean ± σ):   123.425 ns ± 171.953 ns  ┊ GC (mean ± σ):  6.73% ±  5.55%

              ▁▆█▅▁                                              
  ▂▁▂▁▂▂▂▂▂▂▃▅█████▅▄▃▃▃▃▃▃▃▂▂▂▂▂▂▂▂▂▂▂▂▁▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ▃
  71 ns            Histogram: frequency by time          233 ns <

 Memory estimate: 160 bytes, allocs estimate: 1.

julia> @benchmark $M * $M
BenchmarkTools.Trial: 10000 samples with 978 evaluations.
 Range (min … max):   72.008 ns …  13.552 μs  ┊ GC (min … max): 0.00% … 99.10%
 Time  (median):     110.196 ns               ┊ GC (median):    0.00%
 Time  (mean ± σ):   122.994 ns ± 189.384 ns  ┊ GC (mean ± σ):  6.96% ±  5.55%

              ▁▅█▇▃                                              
  ▂▁▂▁▂▂▂▂▂▂▃▄█████▇▅▄▄▄▃▃▃▂▂▂▂▂▂▂▁▁▂▂▂▁▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▁▂▁▂▂▂▂▂ ▃
  72 ns            Histogram: frequency by time          225 ns <

 Memory estimate: 160 bytes, allocs estimate: 1.
```

### Resize Array

```julia
julia> resize!(RM, 4, 4)
4×4 SimpleRDArray{Float64, 2}:
 0.00508115  0.139107  0.049149  1.17347
 0.550149    0.962163  0.27269   0.947301
 0.00244147  0.627738  0.546366  0.0650361
 0.139107    0.27269   0.165403  0.4384

julia> RM[1:3, 1:3] == M # all elements will be move to correct position
true
```

### Performance of `resize!`

```julia
julia> @benchmark resize!(A, 3, 4, 3) setup=(A=SimpleRDArray(ones(3, 3, 3))) evals=1
BenchmarkTools.Trial: 10000 samples with 1 evaluation.
 Range (min … max):  414.000 ns … 26.448 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     600.500 ns              ┊ GC (median):    0.00%
 Time  (mean ± σ):     1.382 μs ±  2.083 μs  ┊ GC (mean ± σ):  0.00% ± 0.00%

  █▇▆▃▂                   ▁▂▂▂▂▂▂▂▁▁ ▁                         ▂
  ██████▆▅▄▁▁▁▁▁▁▃▄▄▄▆▅▆▇████████████████▇▇▇▆▆▇▆▆▆▅▆▆▄▆▆▅▆▅▅▅▅ █
  414 ns        Histogram: log(frequency) by time      8.66 μs <

 Memory estimate: 816 bytes, allocs estimate: 3.
```

If some dimensions will not change, replace those dimension by `:` may helpful.

```julia
julia> @benchmark resize!(A, :, 4, :) setup=(A=SimpleRDArray(ones(3, 3, 3))) evals=1
BenchmarkTools.Trial: 10000 samples with 1 evaluation.
 Range (min … max):  227.000 ns … 23.268 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     257.000 ns              ┊ GC (median):    0.00%
 Time  (mean ± σ):   887.353 ns ±  1.539 μs  ┊ GC (mean ± σ):  0.00% ± 0.00%

  █▁▁                   ▁▃▂▂▂▁▁▁                               ▁
  ████▆▆▅▅▃▁▁▁▁▁▁▁▁▁▁▁▃▇████████████████▇▇▇▇▇▆▆▅▆▆▆▅▆▅▆▅▄▆▅▄▄▄ █
  227 ns        Histogram: log(frequency) by time      6.44 μs <

 Memory estimate: 816 bytes, allocs estimate: 2.
```

## Define your own resizable array type

If you want to defined your own array type, the only need to defined some methods.

### Dense arrays

If your array is a dense array, declare it as a subtype of `AbstractRDArray` is a convenient way, where some important methods of `AbstractRDArray` are pre-defined.

For a subtype of `AbstractRDArray` like `RDArray`, the interfaces is:
| Required methods                                                     | Brief description                         |
| :------------------------------------------------------------------- | :---------------------------------------- |
| `Base.parent(A::RDArray)`                                            | Returns a dense array containing the data |
| `ArrayInterface.parent_type(::Type{<:RDArray})`                      | Returns the type of its parent            |
| `ResizingTools.getsize(A::RDArray{T,N}) where {T,N}`                 | Returns the dimensions of `A`             |
| `ResizingTools.setsize!(A::RDArray{T,N}, dims::Dims{N}) where {T,N}` | Mutates the dimensions of `A` into `dims` |

| Optional methods                                     | Default definition                        | Brief description                         |
| :--------------------------------------------------- | :---------------------------------------- | :---------------------------------------- |
| `ResizingTools.getsize(A::RDArray, i::Int)`          | `getsize(A)[i]`                           | Returns the `i`th dimension of `A`        |
| `ResizingTools.setsize!(A::RDArray, d::Int, i::Int)` | `setsize!(A, setindex(getsize(A), d, i))` | Mutates `i`th dimension of `A` into `dim` |
Then your type `RDArray` will works like a dense array but resizable.

### Other arrays

If your array is a normal array instead of dense array, you should defined all methods below and [required methods for `AbstractArray`](https://docs.julialang.org/en/v1/manual/interfaces/#man-interface-array).