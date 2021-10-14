module ResizingTools

using ArrayInterface
using ArrayInterface: has_parent, parent_type
using LinearAlgebra: AdjOrTrans, AdjOrTransAbsVec, AdjOrTransAbsMat
using Static

export Size, set!, to_dims, getsize, setsize!
export resize_buffer!, resize_buffer_dim!
export SimpleRDArray

# tools for define and access size
include("size.jl")
# core, defined sizehint! and resize! and related methods
include("resize.jl")
# some abstract type with some pre-defined methods
include("abstract.jl")
# some implementation of resizable array
include("example/simplerdarray.jl")

end # module
