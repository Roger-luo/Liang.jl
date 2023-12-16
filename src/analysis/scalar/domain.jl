function Traits.Domain.domain(node::Num.Type)
    @match node begin
        Num.Zero => Domain.Natural
        Num.One => Domain.Natural
        Num.Real(_) => Domain.Real
        Num.Imag(_) => Domain.Imag
        Num.Complex(_) => Domain.Complex
    end
end

function Traits.Domain.domain(node::Scalar.Type)
    @match node begin
        Scalar.Constant(x) => domain(x)
        Scalar.Pi => Domain.Real
        Scalar.Euler => Domain.Real
        Scalar.Hbar => Domain.Real
        Scalar.Variable(_) => Domain.Unknown
        Scalar.Neg(x) => domain(x)
        Scalar.Conj(x) => domain(x)
        Scalar.Abs(x) => real(domain(x))
        Scalar.Exp(x) => exp(domain(x))
        Scalar.Log(x) => log(domain(x))
        Scalar.Sqrt(x) => sqrt(domain(x))

        Scalar.Add(coeffs, terms) => begin
            term_domain = mapreduce(union, terms) do term, coeff
                domain(term) * domain(coeff)
            end
            domain(coeffs) + term_domain
        end
        Scalar.Mul(coeffs, terms) => begin
            term_domain = mapreduce(union, terms) do term, coeff
                domain(term)^domain(coeff)
            end
            domain(coeffs) * term_domain
        end

        Scalar.Pow(x, y) => domain(x)^domain(y)
        Scalar.Div(x, y) => domain(x) / domain(y)

        # TODO: infer this by checking Base.infer_return_type (1.11)?
        Scalar.JuliaCall(_) => Domain.Unknown
        # TODO: actually infer this by looking up the routine
        # definition and checking the return type
        Scalar.RoutineCall(_) => Domain.Unknown
        Scalar.Subscript(_) => Domain.Unknown
        Scalar.Partial(x) => domain(x)
        Scalar.Derivative(x) => domain(x)
        # TODO: infer this by checking the input expression, e.g
        # impl domain inference on operator expression.
        Scalar.Tr(x) => Domain.Unknown
        Scalar.Det(x) => Domain.Unknown

        Scalar.Domain(_, domain_annotation) => domain_annotation
        Scalar.Unit(x) => domain(x)
    end
end
