struct Rule{Data}
    lhs::Data
    rhs::Data
end

"""
    wildcard(expr_type)

Returns a wildcard pattern of given expr type that matches any expression.
"""
wildcard(expr_type) = not_implemented_error()
