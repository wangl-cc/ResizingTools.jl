var documenterSearchIndex = {"docs":
[{"location":"references/#References","page":"References","title":"References","text":"","category":"section"},{"location":"references/","page":"References","title":"References","text":"Modules = [ResizingTools]","category":"page"},{"location":"references/#ResizingTools.AbstractRDArray","page":"References","title":"ResizingTools.AbstractRDArray","text":"AbstractRDArray{T,N} <: DenseArray{T,N}\n\nN-dimensional resizable dense array with elements of type T with some pre-defined array methods.\n\n\n\n\n\n","category":"type"},{"location":"references/#ResizingTools.SimpleRDArray","page":"References","title":"ResizingTools.SimpleRDArray","text":"SimpleRDArray{T,N} <: AbstractRDArray{T,N}\n\nA simple implementation of resizable dense array.\n\n\n\n\n\n","category":"type"},{"location":"references/#ResizingTools.Size","page":"References","title":"ResizingTools.Size","text":"Size{N}\n\nA mutable warpper of NTuple{N,Int} used to represent the dimension of an resizable array. Mutate 'i'th dimension to ndim by sz[i] = ndim mutate the whole dimensions to ndims by set!(sz, ndims).\n\n\n\n\n\n","category":"type"},{"location":"references/#Base.resize!-Tuple{AbstractArray, Any, Integer}","page":"References","title":"Base.resize!","text":"Base.resize!(A::AbstractArray{T,N}, I, i::Integer)\n\nResize the ith dimension to I, where I can be an integer or a colon or an iterator.\n\n\n\n\n\n","category":"method"},{"location":"references/#Base.resize!-Union{Tuple{N}, Tuple{T}, Tuple{AbstractArray{T, N}, Tuple{Vararg{Any, N}}}} where {T, N}","page":"References","title":"Base.resize!","text":"Base.resize!(A::AbstractArray{T,N}, sz)\n\nResize A to sz. sz can be a tuple of integer or Colon or iterator.\n\n\n\n\n\n","category":"method"},{"location":"references/#ResizingTools.getsize-Tuple{AbstractArray, Integer}","page":"References","title":"ResizingTools.getsize","text":"getsize(A::AbstractArray, [dim])\n\nReturn the dimensions of A unlike size which may not return a NTuple{N,Int}. For a AbstractRDArray, convert(Tuple, getsize(A)) is the default implementation of size(A).\n\n\n\n\n\n","category":"method"},{"location":"references/#ResizingTools.isresizable-Tuple{AbstractArray}","page":"References","title":"ResizingTools.isresizable","text":"isresizable(A::AbstractArray)\n\nCheck if the type of A is resizable.\n\ninfo: Info\nisresizable(A) for a Vector or a BitVector will return false even which can be resized by resize!(A, n).\n\n\n\n\n\n","category":"method"},{"location":"references/#ResizingTools.mapindex-Tuple{AbstractArray, Tuple}","page":"References","title":"ResizingTools.mapindex","text":"mapindex(A::AbstractArray, I::Tuple)\nmapindex(A::AbstractArray, i::Integer, I)\n\nMap the index or indices I of A to index of parent(A).\n\n\n\n\n\n","category":"method"},{"location":"references/#ResizingTools.setsize!-Tuple{AbstractArray, Integer, Integer}","page":"References","title":"ResizingTools.setsize!","text":"setsize!(A::AbstractArray, d::Integer, i::Integer)\n\nSet the ith dimension to d.\n\n\n\n\n\n","category":"method"},{"location":"references/#ResizingTools.setsize!-Union{Tuple{N}, Tuple{T}, Tuple{AbstractArray{T, N}, Tuple{Vararg{Any, N}}}} where {T, N}","page":"References","title":"ResizingTools.setsize!","text":"setsize!(A::AbstractArray{T,N}, sz) where {T,N}\n\nSet the size of A to sz\n\n\n\n\n\n","category":"method"},{"location":"interfaces/#Resizing-Interfaces","page":"Resizing Interfaces","title":"Resizing Interfaces","text":"","category":"section"},{"location":"interfaces/#Resizable-Dense-Array","page":"Resizing Interfaces","title":"Resizable Dense Array","text":"","category":"section"},{"location":"interfaces/","page":"Resizing Interfaces","title":"Resizing Interfaces","text":"AbstractRDArray is a subtype of DenseArray with some predefined methods. So if an array type RDArray is a subtype of DenseArray, a convenient way is to make it a subtype of AbstractRDArray, the defined methods below:","category":"page"},{"location":"interfaces/","page":"Resizing Interfaces","title":"Resizing Interfaces","text":"Required methods Brief description\nBase.parent(A::RDArray) Returns a dense array contining the data, which must be resizable.\nArrayInterface.parent_type(::Type{<:RDArray}) Returns the type of its parent\nResizingTools.getsize(A::RDArray{T,N}) where {T,N} Returns the dimensions of A","category":"page"},{"location":"interfaces/","page":"Resizing Interfaces","title":"Resizing Interfaces","text":"Optional methods Default definition Brief description\nResizingTools.getsize(A::RDArray, i::Int) getsize(A)[i] Returns the ith dimension of A\nResizingTools.setsize!(A::RDArray{T,N}, dims::Dims{N}) where {T,N} A (do nothing). Mutates the dimensions of A into dims\nResizingTools.has_setsize(::Type{T}) where {T<:RDArray} false Whether setsize!(A::T, dims) were defined. if it's true, the default setsize!(A, d, i) will do nothing.\nResizingTools.setsize!(A::RDArray, d::Int, i::Int) setsize!(A, setindex(getsize(A), d, i)) Mutates ith dimension of A into dim\nResizingTools.mapindex(A::RDArray, I::Tuple) I Map the index(s) I of A to index(s) of parent(A)\nResizingTools.mapindex(A::RDArray, i, I) I Map the i-dim index(s) I of A to index(s) of parent(A)","category":"page"},{"location":"interfaces/","page":"Resizing Interfaces","title":"Resizing Interfaces","text":"Note: To resize! an array, parent_type of the array must be resizable such as Vector or SimpleRDArray.","category":"page"},{"location":"interfaces/#Normal-Case","page":"Resizing Interfaces","title":"Normal Case","text":"","category":"section"},{"location":"interfaces/","page":"Resizing Interfaces","title":"Resizing Interfaces","text":"If your array type is not a dense array, or you don't want to make it a subtype of AbstractRDArray. You must define more methods in Julia array interfaces.","category":"page"},{"location":"#Introduction","page":"Introduction","title":"Introduction","text":"","category":"section"},{"location":"","page":"Introduction","title":"Introduction","text":"ResizingTools provide some tools to help you resize multi-dimensional arrays with a set of interface methods. Besides, there is a simple implementation of resizable dense array type named SimpleRDArray as a resizable alternative of Array.","category":"page"},{"location":"#Get-started-with-SimpleRDArray","page":"Introduction","title":"Get started with SimpleRDArray","text":"","category":"section"},{"location":"","page":"Introduction","title":"Introduction","text":"SimpleRDArray is a simple implementation of the resizable dense array, which can be created simply:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"using ResizingTools\nM = reshape(1:9, 3, 3)\nRM = SimpleRDArray(M)\nM == RM","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"Once a SimpleRDArray is created, you can almost do anything with which likes a normal Array with similar performance:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"using BenchmarkTools\n@benchmark $RM * $RM\n@benchmark $M * $M\nRM * RM == M * M","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"Besides, a SimpleRDArray can be resized in many ways:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"resize!(RM, (4, 4)) # resize RM to 4 * 4\nRM[1:3,1:3] == M\nresize!(RM, 3, 2) # resize the 2nd dimension of RM to 3\nRM[4, :] .= 0\nresize!(RM, Bool[1, 1, 0, 1], 1) # delete RM[3, :]","category":"page"}]
}
