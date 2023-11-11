using Liang.Match: @match
using Liang.Expression: Scalar, Num
using Liang.Traits: PartialEq
using ExproniconLite


@derive Scalar[PartialEq]

x = Scalar.Sum(
    coeffs=1.0,
    terms=Dict(
        Scalar.Constant(1.0) => 1.0,
        Scalar.Constant(2.0) => 2.0,
    )
)

lhs = Num.One
rhs = 1
@macroexpand @match (lhs, rhs) begin
    (Real(x), Real(y)) => x == y
    (Imag(x), Imag(y)) => x == y
    (Complex(x, y), Complex(a, b)) => x == a && y == b
    _ => true
end

function foo(x)
    @match x begin
        Scalar.Sum(coeffs, terms) => terms
    end
end

PartialEq.eq(x.terms, Dict(
    Scalar.Constant(1.0) => Num.One,
    Scalar.Constant(2.0) => Num.Real(2.0),
))

@code_warntype foo(x)
