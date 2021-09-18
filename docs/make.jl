using Documenter
using ResizingTools
using BenchmarkTools

makedocs(;
    sitename="ResizingTools.jl",
    pages=["index.md", "interfaces.md", "references.md"],
)

deploydocs(; repo="github.com/wangl-cc/ResizingTools.jl.git")
