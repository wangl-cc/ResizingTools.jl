using Documenter
using ResizingTools
using BenchmarkTools

DocMeta.setdocmeta!(ResizingTools, :DocTestSetup, :(using ResizingTools); recursive=true)

makedocs(;
    sitename="ResizingTools.jl",
    pages=["index.md", "interfaces.md", "references.md"],
)

deploydocs(; repo="github.com/wangl-cc/ResizingTools.jl.git")
