"""
$INTERFACE

Run canonicalize on given expression. This is an API for
defining the canonicalization transform of an expression type.
"""
@interface (canonicalize(node::E)::E) where {E} = not_implemented_error()

"""
$INTERFACE

Return the corresponding value expression type of given expression type.
"""
@interface value_expr(::Type{E}) where {E} = not_implemented_error()
