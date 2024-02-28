using Liang.Expression.Prelude
using Liang.Interpret
using Liang.Data.Prelude
using LinearAlgebra
using LuxurySparse

value1 = OpValue.Pauli([0x00, 0x01])
value2 = OpValue.Perm(2, PermMatrix([1, 2], Scalar.Type[1, 1]))

xmat(a)
