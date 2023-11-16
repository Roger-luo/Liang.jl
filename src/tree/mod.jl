using Liang.Tools.Interface: INTERFACE_LIST

"""
A set of interface for tree.

$INTERFACE_LIST
"""
module Tree

using Liang: not_implemented_error
using Liang.Tools.Interface: @interface, INTERFACE

"""
$INTERFACE

Return the children of a node.
"""
@interface children(node) = []

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

Check if a node is an infix node/operator.
"""
@interface is_infix(node) = false

"""
$INTERFACE

Return the precedence of an infix node/operator.
"""
@interface precedence(node)::Int = 0

"""
$INTERFACE

Substitute a (non-leaf) node with given children.
"""
@interface substitute(node, children::Tuple) = not_implemented_error()

include("inline.jl")

end # module Tree
