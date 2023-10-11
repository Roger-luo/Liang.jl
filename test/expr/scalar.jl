using Liang.Data
using Liang.Expression: Scalar
x = Num.Real(1.0)
convert(Real, Num.Real(1.0))

Real(Scalar.Constant(Num.Real(1.0)))
Complex(Scalar.Constant(1+2im))
Scalar.Constant(pi)
names(@__MODULE__, all=true, imported=true)
Scalar.Wildcard
Scalar.Div(Scalar.Constant(Num.Real(1.0)), Scalar.Constant(Num.Complex(2.0, 3.0)))
x = Scalar.Sum(
    coeffs=1.0,
    terms=Dict(
        Scalar.Constant(1.0) => 1.0,
        Scalar.Constant(2.0) => 2.0,
    )
)

Scalar.Constant(1.5) + Scalar.Variable(:x)
