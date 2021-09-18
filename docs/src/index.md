# Introduction

`ResizingTools` provide some tools to help you resize multi-dimensional arrays
with a set of interface methods. Besides, there is a simple implementation of
resizable dense array type named `SimpleRDArray` as a resizable alternative of
`Array`.

# Get started with `SimpleRDArray`

`SimpleRDArray` is a simple implementation of the resizable dense array, which
can be created simply:

```@repl get-start
using ResizingTools
M = reshape(1:9, 3, 3)
RM = SimpleRDArray(M)
M == RM
```

Once a `SimpleRDArray` is created, you can almost do anything with which likes a
normal `Array` with similar performance:

```@repl get-start
using BenchmarkTools
@benchmark $RM * $RM
@benchmark $M * $M
RM * RM == M * M
```

Besides, a `SimpleRDArray` can be resized in many ways:
```@repl get-start
resize!(RM, (4, 4)) # resize RM to 4 * 4
RM[1:3,1:3] == M
resize!(RM, 3, 2) # resize the 2nd dimension of RM to 3
RM[4, :] .= 0
resize!(RM, Bool[1, 1, 0, 1], 1) # delete RM[3, :]
```
