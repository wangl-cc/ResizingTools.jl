module ResizingTools

using ArrayInterface
using ArrayInterface: has_parent, parent_type
using LinearAlgebra: AdjOrTrans, AdjOrTransAbsVec, AdjOrTransAbsMat
using Static

export SimpleRDArray, Size, getsize, set!, resize_buffer!, resize_buffer_dim!

include("methods.jl")
include("utils.jl")
include("type.jl")

end # module
