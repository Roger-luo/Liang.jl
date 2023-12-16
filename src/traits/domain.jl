module Domain

using Liang: not_implemented_error
using Liang.Tools.Interface: @interface, INTERFACE

"""
$INTERFACE

Annotate the expression with a domain.
"""
domain(x, domain_object) = not_implemented_error()

"""
$INTERFACE

Return the domain of the given expression.
"""
domain(x) = not_implemented_error()

end # module
