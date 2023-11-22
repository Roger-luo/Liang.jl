using Liang.Expression.Prelude
using Liang.Tree
using Liang.Data

canonicalize(comm(Op.X, comm(Op.X, Op.Y), 2))
canonicalize(acomm(Op.X, acomm(Op.X, Op.Y), 2))
canonicalize(Op.X^2 * Op.X^3)
canonicalize(acomm(Op.X, acomm(Op.X, Op.Y), 2))
canonicalize(comm(Op.X, Op.Y, 2)')
canonicalize(2.0 * comm(Op.X, Op.Y, 3)')
