
function interp(::Dict{K, V}, expr::Num.Type) where {K, V}
    @match expr begin
        Num.Zero => zero(Real)
        Num.One => one(Real)
        Num.Real(x) => x
        Num.Imag(x) => x * im
        Num.Complex(x, y) => x + y * im
        _ => InterpResult.Error("Interpreter not implemented for $expr")
    end
end


function interp(scope::Dict{K,  V}, expr) where {K, V}
    @match expr begin
        Scalar.Pi => pi
        Scalar.Euler => MathConstants.e
        Scalar.Hbar => InterpResult.Error("Cannot evaluate Hbar without units")
        Scalar.Variable(x)  => InterpResult.Result(scope[x])
        Scalar.Constant(x) => interp(scope, x)
        Scalar.Neg(x) => -interp(scope, x)
        Scalar.Conj(x) => conj(interp(scope, x))
        Scalar.Abs(x) => abs(interp(scope, x))
        Scalar.Exp(x) => exp(interp(scope, x))
        Scalar.Log(x) => log(interp(scope, x))
        Scalar.Max(terms) => max(interp.(scope, terms)...) 
        Scalar.Min(terms) => min(interp.(scope, terms)...)
        Scalar.Pow(x, y) => interp(scope, x) ^ interp(scope, y)
        Scalar.Div(x, y) => interp(scope, x) / interp(scope, y)
        Scalar.Add(coeffs, terms) => begin 
            sum(zip(values(terms), keys(terms));init=interp(scope, coeffs)) do (num, term)
                interp(scope, num) * interp(scope, term)
            end
        end
        Scalar.Mul(coeffs, terms) => begin 
            prod(zip(values(terms), keys(terms));init=interp(scope, coeffs)) do (num, term)
                interp(scope, term) ^ interp(scope, num)
            end
        end
        _ => InterpResult.Error("Interpreter not implemented for $expr")
    end
    
end

