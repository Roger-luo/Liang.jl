function interpret(expr::Scalar.Type, scope::Dict{Variable.Type,Any})::Num.Type
    @match expr begin
        Scalar.Variable(x) => get_value(x, scope)::Num.Type
        Scalar.Constant(x) => x
        Scalar.Pi => Num.Real(pi)
        Scalar.Euler => Num.Real(ℯ)

        # TODO: evaluate this based on units
        Scalar.Hbar => Num.Real(1)

        Scalar.Neg(x) => -interpret(x, scope)
        Scalar.Conj(x) => conj(interpret(x, scope))
        Scalar.Abs(x) => abs(interpret(x, scope))
        Scalar.Exp(x) => exp(interpret(x, scope))
        Scalar.Log(x) => log(interpret(x, scope))
        Scalar.Sqrt(x) => sqrt(interpret(x, scope))

        Scalar.Add(coeffs, terms) => coeffs + mapreduce(+, terms) do term, coeff
            interpret(term, scope) * coeff
        end
        Scalar.Mul(coeffs, terms) => coeffs * mapreduce(*, terms) do term, coeff
            interpret(term, scope)^coeff
        end
        Scalar.Max(terms) => mapreduce(max, terms) do term
            interpret(term, scope)
        end
        Scalar.Max(terms) => mapreduce(min, terms) do term
            interpret(term, scope)
        end
        Scalar.Pow(base, exp) => interpret(base, scope)^interpret(exp, scope)
        Scalar.Div(num, den) => interpret(num, scope) / interpret(den, scope)
        Scalar.JuliaCall(mod, name, args) => begin
            fn = getfield(mod, name)
            values = map(args) do term
                interpret(term, scope)
            end
            fn(values...)
        end
        Scalar.RoutineCall(name, args) => error("not impl")
        Scalar.Subscript(ref, indices) => begin
            values = map(indices) do idx
                interpret(idx, scope)::Int
            end
            return get_value(ref, scope)[values...]::Num.Type
        end
        Scalar.Partial(_) => error("not impl yet")
        Scalar.Derivative(_) => error("not impl yet")
        Scalar.Det(op::Op.Type) => det(interpret(op, scope))
        Scalar.Tr(op::Op.Type) => tr(interpret(op, scope))
        Scalar.Domain(x) => interpret(x, scope)
        Scalar.Unit(x) => interpret(x, scope)

        _ => error("unsupported scalar expression: $expr")
    end
end
