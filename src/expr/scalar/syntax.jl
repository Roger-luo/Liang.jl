for op in [:+, :-, :*, :/, :\, :^]
    @eval function Base.$(op)(lhs::Num.Type, rhs::Num.Type)
        return Base.$(op)(Number(lhs), Number(rhs))
    end

    @eval function Base.$(op)(lhs::Num.Type, rhs::Number)
        return Base.$(op)(Number(lhs), rhs)
    end

    @eval function Base.$(op)(lhs::Number, rhs::Num.Type)
        return Base.$(op)(rhs, lhs)
    end
end

Base.:(+)(x::Scalar.Type) = x
Base.:(-)(x::Scalar.Type) = Scalar.Neg(x)

# some overloads for the syntax of scalar expressions
Base.:(+)(lhs::Scalar.Type, rhs::Number) = lhs + Scalar.Constant(rhs)
Base.:(+)(lhs::Number, rhs::Scalar.Type) = Scalar.Constant(lhs) + rhs

function Base.:(+)(lhs::Scalar.Type, rhs::Scalar.Type)
    @match (lhs, rhs) begin
        (Scalar.Constant(x), Scalar.Constant(y)) => Scalar.Constant(x + y)
        (_, Scalar.Constant(_)) => Scalar.Sum(rhs, Dict(lhs => 1))
        (Scalar.Constant(_), _) => Scalar.Sum(lhs, Dict(rhs => 1))
        _ => Scalar.Sum(Scalar.Constant(0), Dict(lhs => 1, rhs => 1))
    end
end

Base.:(-)(lhs::Scalar.Type, rhs::Number) = lhs - Scalar.Constant(rhs)
Base.:(-)(lhs::Number, rhs::Scalar.Type) = Scalar.Constant(lhs) - rhs

function Base.:(-)(lhs::Scalar.Type, rhs::Scalar.Type)
    @match (lhs, rhs) begin
        (Scalar.Constant(x), Scalar.Constant(y)) => Scalar.Constant(x - y)
        (_, Scalar.Constant(_)) => Scalar.Sum(-rhs, Dict(lhs => 1))
        (Scalar.Constant(_), _) => Scalar.Sum(lhs, Dict(rhs => -1))
        _ => Scalar.Sum(Scalar.Constant(0), Dict(lhs => 1, rhs => -1))
    end
end

Base.:(*)(lhs::Scalar.Type, rhs::Number) = lhs * Scalar.Constant(rhs)
Base.:(*)(lhs::Number, rhs::Scalar.Type) = Scalar.Constant(lhs) * rhs

function Base.:(*)(lhs::Scalar.Type, rhs::Scalar.Type)
    @match (lhs, rhs) begin
        (Scalar.Constant(x), Scalar.Constant(y)) => Scalar.Constant(x * y)
        (_, Scalar.Constant(_)) => Scalar.Prod(rhs, Dict(lhs => 1))
        (Scalar.Constant(_), _) => Scalar.Prod(lhs, Dict(rhs => 1))
        _ => Scalar.Prod(Scalar.Constant(0), Dict(lhs => 1, rhs => 1))
    end
end

Base.:(/)(lhs::Scalar.Type, rhs::Number) = lhs / Scalar.Constant(rhs)
Base.:(/)(lhs::Number, rhs::Scalar.Type) = Scalar.Constant(lhs) / rhs

function Base.:(/)(lhs::Scalar.Type, rhs::Scalar.Type)
    return Scalar.Div(lhs, rhs)
end

Base.:(\)(lhs::Scalar.Type, rhs::Number) = lhs \ Scalar.Constant(rhs)
Base.:(\)(lhs::Number, rhs::Scalar.Type) = Scalar.Constant(lhs) \ rhs
function Base.:(\)(lhs::Scalar.Type, rhs::Scalar.Type)
    return Scalar.Div(rhs, lhs)
end

Base.:(^)(lhs::Scalar.Type, rhs::Number) = lhs^Scalar.Constant(rhs)
Base.:(^)(lhs::Number, rhs::Scalar.Type) = Scalar.Constant(lhs)^rhs
function Base.:(^)(lhs::Scalar.Type, rhs::Scalar.Type)
    return Scalar.Pow(lhs, rhs)
end

Base.abs(x::Scalar.Type) = Scalar.Abs(x)
Base.exp(x::Scalar.Type) = Scalar.Exp(x)
Base.log(x::Scalar.Type) = Scalar.Log(x)
Base.sqrt(x::Scalar.Type) = Scalar.Sqrt(x)

# Index
Base.abs(x::Index.Type) = Index.Abs(x)
Base.:(+)(x::Index.Type) = x
Base.:(-)(x::Index.Type) = Index.Neg(x)
Base.:(+)(lhs::Index.Type, rhs::Index.Type) = Index.Add(lhs, rhs)
Base.:(+)(lhs::Index.Type, rhs::Int) = lhs + Index.Constant(rhs)
Base.:(+)(lhs::Int, rhs::Index.Type) = Index.Constant(lhs) + rhs
Base.:(-)(lhs::Index.Type, rhs::Index.Type) = Index.Sub(lhs, rhs)
Base.:(-)(lhs::Index.Type, rhs::Int) = lhs - Index.Constant(rhs)
Base.:(-)(lhs::Int, rhs::Index.Type) = Index.Constant(lhs) - rhs
Base.:(*)(lhs::Index.Type, rhs::Index.Type) = Index.Mul(lhs, rhs)
Base.:(*)(lhs::Index.Type, rhs::Int) = lhs * Index.Constant(rhs)
Base.:(*)(lhs::Int, rhs::Index.Type) = Index.Constant(lhs) * rhs
Base.:(/)(lhs::Index.Type, rhs::Index.Type) = Index.Div(lhs, rhs)
Base.:(/)(lhs::Index.Type, rhs::Int) = lhs / Index.Constant(rhs)
Base.:(/)(lhs::Int, rhs::Index.Type) = Index.Constant(lhs) / rhs
Base.:(\)(lhs::Index.Type, rhs::Index.Type) = Index.Div(rhs, lhs)
Base.:(\)(lhs::Index.Type, rhs::Int) = lhs \ Index.Constant(rhs)
Base.:(\)(lhs::Int, rhs::Index.Type) = Index.Constant(lhs) \ rhs
Base.:(^)(lhs::Index.Type, rhs::Index.Type) = Index.Pow(lhs, rhs)
Base.:(^)(lhs::Index.Type, rhs::Int) = lhs^Index.Constant(rhs)
Base.:(^)(lhs::Int, rhs::Index.Type) = Index.Constant(lhs)^rhs
Base.rem(lhs::Index.Type, rhs::Index.Type) = Index.Rem(lhs, rhs)
Base.rem(lhs::Index.Type, rhs::Int) = lhs % Index.Constant(rhs)
Base.rem(lhs::Int, rhs::Index.Type) = Index.Constant(lhs) % rhs

function parse_var(f, s::AbstractString)
    if (m = match(r"%([0-9]+)", s); !isnothing(m))
        id = parse(Int64, m.captures[1])
        id > 0 || error("invalid SSA id: $id ≤ 0")
        return f(; name=Symbol(s), id)
    else
        return f(; name=Symbol(s))
    end
end

# variable syntax
macro scalar_str(s::AbstractString)
    return parse_var(Scalar.Variable, s)
end

macro index_str(s::AbstractString)
    return parse_var(Index.Variable, s)
end

struct RoutineStub
    name::Symbol
end

(stub::RoutineStub)(args::Scalar.Type...) = Scalar.RoutineCall(stub.name, collect(args))

macro routine_str(s::AbstractString)
    return RoutineStub(Symbol(s))
end

# overload of some common Julia scalar function
for fn in [
    :acos,
    :acosd,
    :acosh,
    :acot,
    :acotd,
    :acoth,
    :acsc,
    :acscd,
    :acsch,
    :asec,
    :asecd,
    :asech,
    :asin,
    :asind,
    :asinh,
    :atan,
    :atand,
    :atanh,
    :cbrt,
    :cos,
    :cosc,
    :cosd,
    :cosh,
    :cospi,
    :cot,
    :cotd,
    :coth,
    :csc,
    :cscd,
    :csch,
    :exp10,
    :exp2,
    :expm1,
    :exponent,
    :fourthroot,
    :log10,
    :log1p,
    :log2,
    :max,
    :min,
    :mod2pi,
    :modf,
    :rem2pi,
    :sec,
    :secd,
    :sech,
    :sin,
    :sinc,
    :sincos,
    :sincosd,
    :sincospi,
    :sind,
    :sinh,
    :sinpi,
    :tan,
    :tand,
    :tanh,
    :tanpi,
]
    @eval Base.$fn(x::Scalar.Type) = Scalar.JuliaCall(Base, $(QuoteNode(fn)), [x])
end
