"""
$INTERFACE

Return the number of sites of given expression.
"""
@interface n_sites(node)::Index.Type = not_implemented_error()

assert_n_sites_equal(lhs, rhs) = assert_equal(lhs, rhs, "number of sites mismatch")

n_sites(node::Op.Type) = canonicalize(n_sites_not_canonical(node))

function n_sites_not_canonical(node::Op.Type)
    @match node begin
        Op.Constant(op) => n_sites(op, curr)
        Op.Variable(; name, id) => Index.NSites(; name, id)
        Op.Add(terms) => reduce(assert_n_sites_equal, n_sites.(keys(terms)))
        Op.Mul(op1, op2) => assert_n_sites_equal(n_sites(op1), n_sites(op2))
        Op.Kron(op1, op2) => n_sites(op1) + n_sites(op2)
        Op.Comm(op1, op2) => assert_n_sites_equal(n_sites(op1), n_sites(op2))
        Op.AComm(op1, op2) => assert_n_sites_equal(n_sites(op1), n_sites(op2))
        Op.Pow(op, _) => n_sites(op)
        Op.KronPow(base, exp) => n_sites(base) * exp
        Op.Adjoint(op) => n_sites(op)
        # NOTE: when subscript is specified
        # the decorated operator must be a #subscript-site operator
        # thus the total number of sites is the maximum of the indices
        Op.Subscript(op, indices) => reduce(max, indices)
        # Op.Sum(region, term) => begin
        #     n_sites(term) # this gives the expression to eval
        # end
        # single site leaf node
        _ => Index.Constant(1)
    end
end
