module Print

using Liang: not_implemented_error
using Liang.Tools.Interface: @interface, INTERFACE, INTERFACE_LIST
using Liang.Tree: Tree

TREE_PRINT_NOTE = """
!!! note
    This is not the same interface as `Tree` module but a specialized interface
    for `Print` module. This is useful when multiple expressions of different
    types are nested. Give developers finer control over how to print the children
    of a node.
"""

"""
$INTERFACE

Return the children of a node for printing purposes.

$TREE_PRINT_NOTE
"""
@interface (children(node::T)::Vector{T}) where {T} = Tree.children(node)

"""
$INTERFACE

Return the number of children of the provided node.

$TREE_PRINT_NOTE
"""
@interface n_children(node)::Int = length(children(node))

"""
$INTERFACE

Check if a node is a prefix node/operator.
"""
@interface is_prefix(node) = false

"""
$INTERFACE

Check if a node is an infix node/operator.
"""
@interface is_infix(node) = false

"""
$INTERFACE

Check if a node is a postfix node/operator.
"""
@interface is_postfix(node) = false

"""
$INTERFACE

Return the precedence of an infix node/operator.
"""
@interface precedence(node)::Int = 0

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

Return an iterator of the annotation of the children of a node.
Return an empty iterator if the node has no annotation.
"""
@interface annotations(node) = ()

"""
$INTERFACE

Should the annotation of the children of a node be printed or not.
Return `true` if the annotation should be printed, `false` otherwise.
Default to `false`.
"""
@interface should_print_annotation(node) = false

"""
$INTERFACE

Print the meta info of a node, this will be printed after
calling [`print_node`](@ref).
"""
@interface print_meta(io::IO, node) = nothing

# TODO: remove the color kwargs?

"""
$INTERFACE

Print the annotation of the children of a node, default
to [`inline_print`](@ref).
"""
@interface print_annotation(io::IO, node, annotation; color=nothing) =
    print_annotation(io, annotation)

@interface print_annotation(io::IO, annotation) = inline(io, annotation)

include("tools.jl")
include("inline.jl")
include("text.jl")

end # Print
