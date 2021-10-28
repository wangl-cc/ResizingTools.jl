var documenterSearchIndex = {"docs":
[{"location":"references/#References","page":"References","title":"References","text":"","category":"section"},{"location":"references/","page":"References","title":"References","text":"Modules = [ResizingTools]","category":"page"},{"location":"references/#ResizingTools.BufferType","page":"References","title":"ResizingTools.BufferType","text":"BufferType = Union{Vector,BitVector}\n\nTypes which can be a buffer.\n\n\n\n\n\n","category":"type"},{"location":"references/#ResizingTools.AbstractRDArray","page":"References","title":"ResizingTools.AbstractRDArray","text":"AbstractRDArray{T,N} <: DenseArray{T,N}\n\nN-dimensional resizable dense array with elements of type T with some pre-defined array methods.\n\n\n\n\n\n","category":"type"},{"location":"references/#ResizingTools.AbstractRNArray","page":"References","title":"ResizingTools.AbstractRNArray","text":"AbstractRNArray{T,N} <: AbstractArray{T,N}\n\nN-dimensional resizable (no-dense) array with elements of type T with some pre-defined array methods.\n\n\n\n\n\n","category":"type"},{"location":"references/#ResizingTools.AbstractSize","page":"References","title":"ResizingTools.AbstractSize","text":"AbstractSize{N}\n\nSupertype for all array sizes.\n\n\n\n\n\n","category":"type"},{"location":"references/#ResizingTools.SimpleRDArray","page":"References","title":"ResizingTools.SimpleRDArray","text":"SimpleRDArray{T,N} <: AbstractRDArray{T,N}\n\nA simple implementation of resizable dense array.\n\n\n\n\n\n","category":"type"},{"location":"references/#ResizingTools.Size","page":"References","title":"ResizingTools.Size","text":"Size{N} <: AbstractSize{N}\n\nSize type for resizable arrays, which is a mutable wrapper of Dims{N} to represent the dimension of an resizable array. Mutate dth dimension to n by sz[d] = n mutate the whole dimensions to nsz by set!(sz, nsz).\n\n\n\n\n\n","category":"type"},{"location":"references/#Base.resize!-Tuple{AbstractArray, Integer, Any}","page":"References","title":"Base.resize!","text":"resize!(A::AbstractArray{T,N}, d::Integer, I)\n\nResize the dth dimension to I, where I can be an integer or a colon or an iterator.\n\n\n\n\n\n","category":"method"},{"location":"references/#Base.resize!-Union{Tuple{B}, Tuple{N}, Tuple{T}, Tuple{AbstractArray{T, N}, Tuple{Vararg{Any, N}}}, Tuple{AbstractArray{T, N}, Tuple{Vararg{Any, N}}, B}} where {T, N, B}","page":"References","title":"Base.resize!","text":"resize!(A::AbstractArray{T,N}, sz)\n\nResize A to sz. sz can be a tuple of integer or Colon or iterator.\n\n\n\n\n\n","category":"method"},{"location":"references/#Base.sizehint!-Tuple{AbstractArray, Integer}","page":"References","title":"Base.sizehint!","text":"Base.sizehint!(A::AbstractArray, nl::Integer)\n\nSuggest that array A reserve capacity for at least nl elements. This can improve performance.\n\n\n\n\n\n","category":"method"},{"location":"references/#Base.sizehint!-Union{Tuple{N}, Tuple{T}, Tuple{AbstractArray{T, N}, Tuple{Vararg{Any, N}}}} where {T, N}","page":"References","title":"Base.sizehint!","text":"sizehint!(A::AbstractArray{T,N}, sz::NTuple{N}) where {T,N}\n\nSuggest that array A reserve size for at least sz. This can improve performance.\n\n\n\n\n\n","category":"method"},{"location":"references/#ResizingTools.after_resize!","page":"References","title":"ResizingTools.after_resize!","text":"after_resize!(A::AbstractArray{T,N}, sz::NTuple{N,Any})\nafter_resize!(A::AbstractArray{T,N}, d::Integer, n::Any)\n\nDo something after resize A with given arguments (do nothing by default). This methods is called by resize! with the same arguments.\n\n\n\n\n\n","category":"function"},{"location":"references/#ResizingTools.getsize","page":"References","title":"ResizingTools.getsize","text":"getsize(A::AbstractArray, [dim])\n\nReturns the dimensions of A unlike size which may not return a Dims{N}.\n\nwarning: Warning\nYou should never call this function directly. Use size instead.\n\n\n\n\n\n","category":"function"},{"location":"references/#ResizingTools.has_resize_buffer-Tuple{AbstractArray}","page":"References","title":"ResizingTools.has_resize_buffer","text":"has_resize_buffer(A::AbstractArray)\n\nDetermines if an array has resize_buffer* methods, if not resize!(A, args...) would resize its parent.\n\n\n\n\n\n","category":"method"},{"location":"references/#ResizingTools.isresizable-Tuple{AbstractArray}","page":"References","title":"ResizingTools.isresizable","text":"isresizable(A::AbstractArray)\n\nDetermines if an array is resizable, if not resize!(A, args...) would throw an error.\n\n\n\n\n\n","category":"method"},{"location":"references/#ResizingTools.pre_resize!","page":"References","title":"ResizingTools.pre_resize!","text":"pre_resize!(A::AbstractArray{T,N}, sz::NTuple{N,Any})\npre_resize!(A::AbstractArray{T,N}, d::Integer, n::Any)\n\nDo something before resize A with given arguments (do nothing by default). This method is called by resize! with the same arguments.\n\n\n\n\n\n","category":"function"},{"location":"references/#ResizingTools.resize_buffer!","page":"References","title":"ResizingTools.resize_buffer!","text":"resize_buffer!(A::AbstractArray, nsz...)\n\nImplementation of resize!(A, nsz) where parent(A) is BufferType.\n\n\n\n\n\n","category":"function"},{"location":"references/#ResizingTools.resize_buffer_dim!","page":"References","title":"ResizingTools.resize_buffer_dim!","text":"resize_buffer_dim!(A::AbstractArray, d::Int, I)\n\nImplementation of resize!(A, d, I) where parent(A) is a BufferType.\n\n\n\n\n\n","category":"function"},{"location":"references/#ResizingTools.resize_parent!-Tuple{AbstractArray, Integer}","page":"References","title":"ResizingTools.resize_parent!","text":"resize_parent!(A::AbstractArray, nl::Integer)\n\nResize the parent of A. This method will (and should only) be called by resize_buffer! or resize_buffer_dim!, the default implementation is resize!(parent(A), nl), but for arrays with preserved space, this methods can be override to keep size of parent.\n\n\n\n\n\n","category":"method"},{"location":"references/#ResizingTools.resize_parent!-Union{Tuple{N}, Tuple{T}, Tuple{AbstractArray{T, N}, Tuple{Vararg{Any, N}}}} where {T, N}","page":"References","title":"ResizingTools.resize_parent!","text":"resize_parent!(A::AbstractArray{T,N}, sz::NTuple{N})\n\nThe same as resize_parent!(A, prod(sz).\n\n\n\n\n\n","category":"method"},{"location":"references/#ResizingTools.set!-Union{Tuple{N}, Tuple{Size{N}, Tuple{Vararg{Integer, N}}}} where N","page":"References","title":"ResizingTools.set!","text":"set!(sz::Size{N}, nsz::NTuple{N,Integer})\n\nSet sz to nsz.\n\nExample\n\njulia> sz = Size(1, 2, 3)\nSize{3}((1, 2, 3))\n\njulia> set!(sz, (3, 2, 1))\nSize{3}((3, 2, 1))\n\n\n\n\n\n","category":"method"},{"location":"references/#ResizingTools.setsize!-Tuple{AbstractArray, Integer, Any}","page":"References","title":"ResizingTools.setsize!","text":"setsize!(A::AbstractArray, d::Integer, n) -> AbstractArray\n\nSet the dth dimension to n.\n\n\n\n\n\n","category":"method"},{"location":"references/#ResizingTools.setsize!-Union{Tuple{N}, Tuple{T}, Tuple{AbstractArray{T, N}, Tuple{Vararg{Any, N}}}} where {T, N}","page":"References","title":"ResizingTools.setsize!","text":"setsize!(A::AbstractArray{T,N}, sz) where {T,N} -> AbstractArray\n\nSet the size of A to sz.\n\n\n\n\n\n","category":"method"},{"location":"references/#ResizingTools.size_type-Tuple{AbstractArray}","page":"References","title":"ResizingTools.size_type","text":"size_type(A::AbstractArray)\n\nGet the size type of A, determine the methods of setsize!. The default size_type is NoneSize, which means setsize! will \"do nothing\".\n\n\n\n\n\n","category":"method"},{"location":"references/#ResizingTools.to_dims-Tuple{Tuple}","page":"References","title":"ResizingTools.to_dims","text":"to_dims(inds::Tuple) -> Dims\n\nConvert the given indices to Dims.\n\nnote: Note\nThe given indices should be a return value of to_indices. If inds[i] is an Integer, this function would converted it to Int; If inds[i] is an AbstractVector, this function would return its length.\n\n\n\n\n\n","category":"method"},{"location":"references/#ResizingTools.to_parentinds-Tuple{AbstractArray, Integer, Any}","page":"References","title":"ResizingTools.to_parentinds","text":"to_parentinds(A::AbstractArray, i::Integer, I) -> (i′, I′)\n\nConvert the index(s) I at dth dimension of A to index(s) I′ at d′th dimension of parent(A).\n\n\n\n\n\n","category":"method"},{"location":"references/#ResizingTools.to_parentinds-Tuple{AbstractArray, Tuple}","page":"References","title":"ResizingTools.to_parentinds","text":"to_parentinds(A::AbstractArray, Is::Tuple) -> Is′\n\nConvert the index(s) Is of A to index(s) Is′ of parent(A).\n\n\n\n\n\n","category":"method"},{"location":"manual/#Manual","page":"Manual","title":"Manual","text":"","category":"section"},{"location":"manual/#Predefined-Types","page":"Manual","title":"Predefined Types","text":"","category":"section"},{"location":"manual/#manual-type-normal","page":"Manual","title":"AbstractRNArray","text":"","category":"section"},{"location":"manual/","page":"Manual","title":"Manual","text":"AbstractRNArray is a subtype of AbstractArray with predefined size by getsize:","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"Base.size(A::AbstractRNArray): return getsize(A),\nBase.size(A::AbstractRNArray, d): return getsize(A, d) for 1 <= d <= ndims(A), and 1 for d > ndims(A).","category":"page"},{"location":"manual/#manual-type-dense","page":"Manual","title":"AbstractRDArray","text":"","category":"section"},{"location":"manual/","page":"Manual","title":"Manual","text":"AbstractRDArray is a subtype of DenseArray with some predefined methods:","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"Base.unsafe_convert(::Ptr{T}, A::AbstractRDArray) where {T}: return `Base.unsafe_convert(Ptr{T}, parent(A)),\nBase.elsize(::Type{T}) where {T<:AbstractRDArray}: return Base.elsize(ArrayInterface.parent_type(A)).","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"warning: Warning\nparent_type(::Type{<:AbstractRDArray}) must be a type with above methods.","category":"page"},{"location":"manual/#Resizing-Methods","page":"Manual","title":"Resizing Methods","text":"","category":"section"},{"location":"manual/#manual-methods-sizehint","page":"Manual","title":"sizehint!","text":"","category":"section"},{"location":"manual/","page":"Manual","title":"Manual","text":"This packages provide methods Base.sizehint! for AbstractArray. You can sizehint! with the same arguments sizehint!(A, n) as Base.sizehint!, which suggest that A reserve capacity for at least n. Besides, for multi-dimensional arrays, sizehint!(A, sz::NTuple) is also a convenient way which suggests that array A reserve capacity for at least prod(sz) elements.","category":"page"},{"location":"manual/#manual-methods-resize","page":"Manual","title":"resize!","text":"","category":"section"},{"location":"manual/","page":"Manual","title":"Manual","text":"resize! is the core methods of this package, which provide ways to resizing multi-dimensional arrays. There are two form of resize!:","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"resize!(A, sz::Tuple): Resize A to size sz, where sz can be a tuple accepted by to_indices (Integer, Colon, AbstractVector, etc.),\nresize!(A, d::Integer, I): Resize dth dimension of A to I, where A can be (Integer, Colon, AbstractVector).","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"There are many interface methods for resizing arrays, most of which depends on parent(A) and related methods like parent_type, resize_parent!, etc.","category":"page"},{"location":"manual/#Interfaces","page":"Manual","title":"Interfaces","text":"","category":"section"},{"location":"manual/","page":"Manual","title":"Manual","text":"To create a resizable array type, there are some methods required besides of the interface of AbstractArray.","category":"page"},{"location":"manual/#manual-interface-parent","page":"Manual","title":"Parent","text":"","category":"section"},{"location":"manual/","page":"Manual","title":"Manual","text":"A resizable array type must contain a parent storing data. Thus, Base.parent(A::AbstractArray): which returns the array storing data and ArrayInterface.parent_type(::Type{T}) which returns the type of parent must be defined. Resizing methods like sizehint! and resize! will effect though  parent.","category":"page"},{"location":"manual/#manual-interface-size","page":"Manual","title":"Size","text":"","category":"section"},{"location":"manual/","page":"Manual","title":"Manual","text":"Besides, there are also some methods to access and mutate the size of array. The most important methods are ResizingTools.getsize(A) which returns the size of A and ResizingTools.size_type(::Type{T}), which returns the type of getsize(A) and determine the default methods of setsize!.","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"There are two available size types now:","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"Dims: NTuple of Ints, the normal size type array, and is the default methods. In this case the setsize! will not change anything,\nSize: a mutable wrapper of Dims{N} with setindex! and set!. In this case, setsize!(A, sz) will call set!(getsize(A), sz) and setsize(A, d, i) will call getsize(A)[d] = i.","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"However, if the size of array is a mutable field of Dims, setsize(::Type{S}, A::AbstractArray, sz::Dims{N}) and setsize(::Type{S}, A::AbstractArray, d::Int, i::Int) where S <: Dims  must be defined to mutate the size of array.","category":"page"},{"location":"manual/#Index-transform","page":"Manual","title":"Index transform","text":"","category":"section"},{"location":"manual/","page":"Manual","title":"Manual","text":"In some case, the index of A can't be convert to index of its parent, such as  A' for which A[i, j]' == A'[j, i]. Thus, in these cases, the index of A must be transformed. Define ResizingTools.to_parentinds to do this.","category":"page"},{"location":"manual/#Example","page":"Manual","title":"Example","text":"","category":"section"},{"location":"manual/","page":"Manual","title":"Manual","text":"See the implementation of SimpleRDArray for more details.","category":"page"},{"location":"#Introduction","page":"Introduction","title":"Introduction","text":"","category":"section"},{"location":"","page":"Introduction","title":"Introduction","text":"ResizingTools provide some tools to help you resize multi-dimensional arrays with a set of interface methods. Besides, there is a simple implementation of resizable dense array type named SimpleRDArray as a resizable alternative of Array.","category":"page"},{"location":"#Get-started-with-SimpleRDArray","page":"Introduction","title":"Get started with SimpleRDArray","text":"","category":"section"},{"location":"","page":"Introduction","title":"Introduction","text":"SimpleRDArray is a simple implementation of the resizable dense array, which can be created simply:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"using ResizingTools\nM = reshape(1:9, 3, 3)\nRM = SimpleRDArray(M)\nM == RM","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"Once a SimpleRDArray is created, you can almost do anything with which likes a normal Array with similar performance:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"using BenchmarkTools\n@benchmark $RM * $RM\n@benchmark $M * $M\nRM * RM == M * M","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"Besides, a SimpleRDArray can be resized in many ways:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"resize!(RM, (4, 4)) # resize RM to 4 * 4\nRM[1:3,1:3] == M\nresize!(RM, 2, 3) # resize the 2nd dimension of RM to 3\nRM[4, :] .= 0\nresize!(RM, 1, Bool[1, 1, 0, 1]) # delete at index 3 at 1st dimension","category":"page"}]
}
