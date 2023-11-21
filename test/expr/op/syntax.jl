using Liang.Expression.Prelude
using Liang.Tree
ex = Op.Sum(1:5, Op.X[index"i"] * Op.X[index"i" + 1] + Op.Z[index"i"] * Op.Z[index"i" + 1])
Tree.inline_print(ex)
