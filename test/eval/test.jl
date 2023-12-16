using Base.MathConstants: MathConstants
using Liang: Scalar, Num, Variable

using Liang.Match: @match
using Liang.Data: @data


@data InterpResult begin
    Result(Any)
    Error(String)
end

Base.show(io::IO, x::InterpResult.Type) = begin
    @match x begin
        InterpResult.Result(x) => print(io, x)
        InterpResult.Error(msg) => print(io, msg)
    end
end

for binop in [:max, :min, :kron, :+, :*, :/, :^]
    @eval function Base.$binop(x::InterpResult.Type, y::InterpResult.Type)
        @match (x, y) begin
            (InterpResult.Result(x), InterpResult.Result(y)) => InterpResult.Result($binop(x, y))
            (InterpResult.Error(msg), _) => InterpResult.Error(msg)
            (_, InterpResult.Error(msg)) => InterpResult.Error(msg)
        end
    end
    @eval function Base.$binop(x::InterpResult.Type, y)
        @match x begin
            InterpResult.Result(x) => InterpResult.Result($binop(x, y))
            InterpResult.Error(msg) => InterpResult.Error(msg)
        end
    end
    @eval function Base.$binop(x, y::InterpResult.Type)
        @match y begin
            InterpResult.Result(y) => InterpResult.Result($binop(x, y))
            InterpResult.Error(msg) => InterpResult.Error(msg)
        end
    end
end

for unaryop in [:-, :conj, :abs, :exp, :log, :sqrt]
    @eval function $unaryop(x::InterpResult.Type)
        @match x begin
            InterpResult.Result(x) => InterpResult.Result($unaryop(x))
            InterpResult.Error(msg) => InterpResult.Error(msg)
        end
    end
end


function interp(::Dict{K, V}, expr::Num.Type) where {K, V}
    @match expr begin
        Num.Zero => zero(Real)
        Num.One => one(Real)
        Scalar.Pi => pi
        Scalar.Euler => MathConstants.e
        Scalar.Hbar => InterpResult.Error("Cannot evaluate Hbar without units")
        Num.Real(x) => x
        Num.Imag(x) => x * im
        Num.Complex(x, y) => x + y * im
        _ => InterpResult.Error("Interpreter not implemented for $expr")
    end
end


function interp(scope::Dict{K,  V}, expr) where {K, V}
    @match expr begin
        # Variable and expressions
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


a = Scalar.Variable(Variable.Slot(:a))
c = Scalar.Variable(Variable.Slot(:c))
b = convert(Scalar.Type, 1)




interp(Dict(Varable.Slot(:a) => 2, Variable.Slot(:c) => 4), expr * Scalar.Hbar)