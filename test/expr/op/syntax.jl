using Liang.Expression.Prelude
using Liang.Tree
ex = Op.Sum(1:5, (Op.X[index"i"]%Qubit) * (Op.X[index"i" + 1]%Qubit) + Op.Z[index"i"] * Op.Z[index"i" + 1])
(ex + ex)