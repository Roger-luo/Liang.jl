function get_value(x::Variable.Type, scope::Dict{Variable.Type,Any})
    if haskey(scope, x)
        return scope[x]
    else
        error("expect $x to be assigned")
    end
end

function interpret(expr::Index.Type, scope::Dict{Variable.Type,Any})::Int
    @match expr begin
        Index.Inf => Index.Inf
        Index.Constant(x) => x
        Index.Variable(x) => get_value(x, scope)::Int
        Index.Add(coeffs, terms) => coeffs + mapreduce(+, terms) do term, coeff
            interpret(term, scope) * coeff
        end
        Index.Mul(coeffs, terms) => coeffs * mapreduce(*, terms) do term, coeff
            interpret(term, scope)^coeff
        end
        Index.Div(num, den) => interpret(num, scope) / interpret(den, scope)
        Index.Pow(base, exp) => interpret(base, scope)^interpret(exp, scope)
        Index.Rem(base, mod) => rem(interpret(base, scope), interpret(mod, scope))
        Index.Max(terms) => mapreduce(max, terms) do term
            interpret(term, scope)
        end
        Index.Min(terms) => mapreduce(min, terms) do term
            interpret(term, scope)
        end
        Index.Abs(term) => abs(interpret(term, scope))
        Index.NSites(x) => n_sites(get_value(x, scope))
        Index.AssertEqual(lhs, rhs, msg) => begin
            lhs = interpret(lhs, scope)
            rhs = interpret(rhs, scope)
            lhs == rhs && return lhs
            error(msg)
        end
    end
end
