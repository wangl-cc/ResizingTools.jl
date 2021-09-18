module ResizingTools

using ArrayInterface
using ArrayInterface: has_parent, parent_type
using LinearAlgebra: AdjOrTrans, AdjOrTransAbsVec, AdjOrTransAbsMat
using Static

export SimpleRDArray, Size

include("methods.jl")
include("utils.jl")
include("type.jl")

end # module
