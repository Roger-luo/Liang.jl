using Liang.Expression.Prelude
using Liang.Tree
using Liang.Data
using Liang.Rewrite: Pre, Post
using Liang.Expression: prop_adjoint, merge_nested_add

canonicalize(comm(Op.X, comm(Op.X, Op.Y), 2))
canonicalize(acomm(Op.X, acomm(Op.X, Op.Y), 2))
canonicalize(Op.X^2 * Op.X^3)
canonicalize(acomm(Op.X, acomm(Op.X, Op.Y), 2))
canonicalize(comm(Op.X, Op.Y, 2)')

ex = 2.0 * comm(Op.X, Op.Y, 3)'
ex = prop_adjoint(ex)
ex = merge_nested_add(ex)

ex = canonicalize(2.0 * comm(Op.X, Op.Y, 3)')

ex = prop_adjoint(comm(Op.X, Op.Y, 2)')

merge_nested_add(ex)

