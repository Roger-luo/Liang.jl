"""
A set of interface for tree.

$INTERFACE_LIST
"""
module Tree

using Liang: not_implemented_error
using Liang.Tools.Interface: @interface, INTERFACE, INTERFACE_LIST

"""
$INTERFACE

Return the children of a node.
"""
@interface children(node::T)::Vector{T} where {T} = T[]

"""
$INTERFACE

Substitute a (non-leaf) node with given children.
"""
@interface substitute(node, replace::Dict) = not_implemented_error()

"""
$INTERFACE

Map a function to the children of a node, and return the
new node with the mapped children.

!!! note
    This usually provides better performance than calling
    [`substitute`](@ref) with a dictionary, since it avoids
    unnecessary copying of the node.
"""
@interface map_children(f, node) = not_implemented_error()

"""
$INTERFACE

Check if a node is a leaf node.
"""
@interface is_leaf(node) = isempty(children(node))

"""
$INTERFACE

Print the node
"""
@interface print_node(io::IO, node) = not_implemented_error()

"""
$INTERFACE

Check if a node use custom print. Useful for dynamic
dispatch, e.g a variant in data type.
"""
@interface use_custom_print(node) = false

"""
$INTERFACE

API for overloading custom tree printing behavior.
Useful for dynamic dispatch, e.g a variant in data type.
"""
@interface custom_inline_print(io::IO, node) = not_implemented_error()

"""
$INTERFACE

Check if a node is an infix node/operator.
"""
@interface is_infix(node) = false

"""
$INTERFACE

Return the precedence of an infix node/operator.
"""
@interface precedence(node)::Int = 0

include("inline.jl")

end # module Tree
