using Liang.Expression.Prelude
using Liang.Tree
using Liang.Data
ex = Op.Sum(1:5, (Op.X[index"i"]%Qubit) * (Op.X[index"i" + 1]%Qubit) + Op.Z[index"i"] * Op.Z[index"i" + 1])
(ex + ex)|>Data.pprint
ex |> Tree.text_print

(Op.X + 3 * (Op.Z + Op.Y) + 1.0) |> Tree.text_print

2 * scalar"x" + 1.0 |> Tree.text_print
