function unit(node::Scalar.Type)
    return dimension(unit_prop(node)::Quantity)
end

function unit_prop(node::Scalar.Type)
    no_unit = Quantity(1.0, SymbolicDimensions())
    @match node begin
        Scalar.Hbar => Quantity(1.0, SymbolicDimensions(; m=2, kg=1, s=-1))
        Scalar.Neg(x) => unit_prop(x)
        Scalar.Conj(x) => unit_prop(x)
        Scalar.Abs(x) => unit_prop(x)
        Scalar.Exp(x) => exp(unit_prop(x))
        Scalar.Log(x) => log(unit_prop(x))
        Scalar.Sqrt(x) => sqrt(unit_prop(x))
        # NOTE: we assume that the coefficients
        # have the same units as the terms
        Scalar.Add(coeffs, terms) => mapreduce(+, terms) do term, coeff
            unit_prop(term)
        end
        Scalar.Mul(coeffs, terms) => mapreduce(*, terms) do term, coeff
            unit_prop(term)^Number(coeff)
        end
        Scalar.Pow(x, y) => unit_prop(x)^Number(y)
        Scalar.Div(x, y) => unit_prop(x) / unit_prop(y)
        Scalar.JuliaCall(_) => no_unit
        # TODO: actually infer this by looking up the routine
        Scalar.RoutineCall(_) => error("not supported yet")
        Scalar.Partial(x) => unit_prop(x)
        Scalar.Derivative(x) => unit_prop(x)
        Scalar.Unit(_, unit_annotation) => unit_annotation
        _ => no_unit
    end
end
