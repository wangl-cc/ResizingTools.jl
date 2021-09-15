module ResizingTools

using ArrayInterface
using Static
using ArrayInterface: has_parent, parent_type

export SimpleRDArray, Size

include("methods.jl")
include("utils.jl")
include("type.jl")

end # module
