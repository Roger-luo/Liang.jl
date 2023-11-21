using Liang.Expression.Prelude
using Liang.Tree
ex = Op.Sum(1:5, Op.X[index"i"] * Op.X[index"i" + 1] + Op.Z[index"i"] * Op.Z[index"i" + 1])
Basis(Op.X, Space.Qubit)^2
Tree.inline_print(ex |Basis(Op.X, Space.Qubit)^2 + kron(Op.X, Op.X, Op.I))
