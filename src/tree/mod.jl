"""
A set of interface for tree.
"""
module Tree

using Liang: not_implemented_error
using Liang.Tools.Interface: @interface

@interface children(node) = ()
@interface is_leaf(node) = isempty(children(node))
@interface print_node(io::IO, node) = not_implemented_error()
@interface is_infix(node) = false

include("inline.jl")

end # module Tree
