"""
$SIGNATURES

Propagate conjugate into leaf nodes.
"""
function prop_conj(node::Scalar.Type)
    @match node begin
        Scalar.Conj(Scalar.Constant(x)) => Scalar.Constant(conj(x))
        Scalar.Pi => Scalar.Pi
        Scalar.Euler => Scalar.Euler
        Scalar.Hbar => Scalar.Hbar
        Scalar.Conj(Scalar.Neg(x)) => Scalar.Neg(conj(x))
        Scalar.Conj(Scalar.Conj(x)) => x
        Scalar.Conj(Scalar.Abs(x)) => node
        Scalar.Conj(Scalar.Exp(x)) => Scalar.Exp(conj(x))
        Scalar.Conj(Scalar.Log(x)) => Scalar.Log(conj(x))
        Scalar.Conj(Scalar.Sqrt(x)) => Scalar.Sqrt(conj(x))
        Scalar.Conj(Scalar.Add(coeffs, terms)) => Scalar.Add(
            conj(coeffs),
            map(terms) do term
                conj(term)
            end,
        )
        Scalar.Conj(Scalar.Mul(coeffs, terms)) => Scalar.Mul(
            conj(coeffs),
            map(terms) do term
                conj(term)
            end,
        )
        Scalar.Conj(Scalar.Pow(base, exp)) => Scalar.Pow(conj(base), conj(exp))
        Scalar.Conj(Scalar.Div(lhs, rhs)) => Scalar.Div(conj(lhs), conj(rhs))
        Scalar.Conj(Scalar.Domain(expr, domain)) => Scalar.Domain(conj(expr), domain)
        Scalar.Conj(Scalar.Unit(expr, unit)) => Scalar.Unit(conj(expr), unit)
        _ => node
    end
end
