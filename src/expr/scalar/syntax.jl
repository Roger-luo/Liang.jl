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
Base.:(+)(lhs::Scalar.Type, rhs::Num.Type) = lhs + Scalar.Constant(rhs)
Base.:(+)(lhs::Num.Type, rhs::Scalar.Type) = Scalar.Constant(lhs) + rhs

function Base.:(+)(lhs::Scalar.Type, rhs::Scalar.Type)
    @match (lhs, rhs) begin
        (Scalar.Constant(x), Scalar.Constant(y)) => Scalar.Constant(x + y)
        (_, Scalar.Constant(_)) => Scalar.Add(rhs, Dict(lhs => 1))
        (Scalar.Constant(_), _) => Scalar.Add(lhs, Dict(rhs => 1))
        (x, x) => Scalar.Add(Scalar.Constant(0), Dict(x => 2))
        _ => Scalar.Add(Scalar.Constant(0), Dict(lhs => 1, rhs => 1))
    end
end

Base.:(-)(lhs::Scalar.Type, rhs::Number) = lhs - Scalar.Constant(rhs)
Base.:(-)(lhs::Number, rhs::Scalar.Type) = Scalar.Constant(lhs) - rhs
Base.:(-)(lhs::Scalar.Type, rhs::Num.Type) = lhs - Scalar.Constant(rhs)
Base.:(-)(lhs::Num.Type, rhs::Scalar.Type) = Scalar.Constant(lhs) - rhs

function Base.:(-)(lhs::Scalar.Type, rhs::Scalar.Type)
    @match (lhs, rhs) begin
        (Scalar.Constant(x), Scalar.Constant(y)) => Scalar.Constant(x - y)
        (_, Scalar.Constant(_)) => Scalar.Add(-rhs, Dict(lhs => 1))
        (Scalar.Constant(_), _) => Scalar.Add(lhs, Dict(rhs => -1))
        (x, x) => Scalar.Constant(0)
        _ => Scalar.Add(Scalar.Constant(0), Dict(lhs => 1, rhs => -1))
    end
end

Base.:(*)(lhs::Scalar.Type, rhs::Number) = lhs * Scalar.Constant(rhs)
Base.:(*)(lhs::Number, rhs::Scalar.Type) = Scalar.Constant(lhs) * rhs
Base.:(*)(lhs::Scalar.Type, rhs::Num.Type) = lhs * Scalar.Constant(rhs)
Base.:(*)(lhs::Num.Type, rhs::Scalar.Type) = Scalar.Constant(lhs) * rhs

function Base.:(*)(lhs::Scalar.Type, rhs::Scalar.Type)
    @match (lhs, rhs) begin
        (Scalar.Constant(x), Scalar.Constant(y)) => Scalar.Constant(x * y)
        (_, Scalar.Constant(_)) => Scalar.Mul(rhs, Dict(lhs => 1))
        (Scalar.Constant(_), _) => Scalar.Mul(lhs, Dict(rhs => 1))
        (x, x) => Scalar.Pow(x, Scalar.Constant(2))
        _ => Scalar.Mul(Scalar.Constant(1), Dict(lhs => 1, rhs => 1))
    end
end

Base.:(/)(lhs::Scalar.Type, rhs::Number) = lhs / Scalar.Constant(rhs)
Base.:(/)(lhs::Number, rhs::Scalar.Type) = Scalar.Constant(lhs) / rhs
Base.:(/)(lhs::Scalar.Type, rhs::Num.Type) = lhs / Scalar.Constant(rhs)
Base.:(/)(lhs::Num.Type, rhs::Scalar.Type) = Scalar.Constant(lhs) / rhs

function Base.:(/)(lhs::Scalar.Type, rhs::Scalar.Type)
    lhs == rhs && return Scalar.Constant(1)
    return Scalar.Div(lhs, rhs)
end

Base.:(\)(lhs::Scalar.Type, rhs::Number) = lhs \ Scalar.Constant(rhs)
Base.:(\)(lhs::Number, rhs::Scalar.Type) = Scalar.Constant(lhs) \ rhs
Base.:(\)(lhs::Scalar.Type, rhs::Num.Type) = lhs \ Scalar.Constant(rhs)
Base.:(\)(lhs::Num.Type, rhs::Scalar.Type) = Scalar.Constant(lhs) \ rhs
function Base.:(\)(lhs::Scalar.Type, rhs::Scalar.Type)
    lhs == rhs && return Scalar.Constant(1)
    return Scalar.Div(rhs, lhs)
end

Base.:(^)(lhs::Scalar.Type, rhs::Number) = lhs^Scalar.Constant(rhs)
Base.:(^)(lhs::Number, rhs::Scalar.Type) = Scalar.Constant(lhs)^rhs
Base.:(^)(lhs::Scalar.Type, rhs::Num.Type) = lhs^Scalar.Constant(rhs)
Base.:(^)(lhs::Num.Type, rhs::Scalar.Type) = Scalar.Constant(lhs)^rhs
function Base.:(^)(lhs::Scalar.Type, rhs::Scalar.Type)
    return Scalar.Pow(lhs, rhs)
end

Base.abs(x::Scalar.Type) = Scalar.Abs(x)
Base.exp(x::Scalar.Type) = Scalar.Exp(x)
Base.log(x::Scalar.Type) = Scalar.Log(x)
Base.sqrt(x::Scalar.Type) = Scalar.Sqrt(x)

# Index
Base.abs(x::Index.Type) = Index.Abs(x)

"""
$SIGNATURES

Assert that the index `lhs` and `rhs` are equal.
"""
function assert_equal(lhs::Index.Type, rhs::Index.Type, msg::String = "")
    lhs == rhs && return lhs # short-circuit
    return Index.AssertEqual(lhs, rhs, msg)
end

Base.:(+)(x::Index.Type) = x
Base.:(-)(x::Index.Type) = Index.Neg(x)
Base.:(+)(lhs::Index.Type, rhs::Index.Type) = Index.Add(lhs, rhs)
Base.:(+)(lhs::Index.Type, rhs::Int) = Index.Add(lhs, rhs)
Base.:(+)(lhs::Int, rhs::Index.Type) = Index.Add(lhs, rhs)
Base.:(-)(lhs::Index.Type, rhs::Index.Type) = Index.Sub(lhs, rhs)
Base.:(-)(lhs::Index.Type, rhs::Int) = Index.Sub(lhs, rhs)
Base.:(-)(lhs::Int, rhs::Index.Type) = Index.Sub(lhs, rhs)
Base.:(*)(lhs::Index.Type, rhs::Index.Type) = Index.Mul(lhs, rhs)
Base.:(*)(lhs::Index.Type, rhs::Int) = Index.Mul(lhs, rhs)
Base.:(*)(lhs::Int, rhs::Index.Type) = Index.Mul(lhs, rhs)
Base.:(/)(lhs::Index.Type, rhs::Index.Type) = Index.Div(lhs, rhs)
Base.:(/)(lhs::Index.Type, rhs::Int) = Index.Div(lhs, rhs)
Base.:(/)(lhs::Int, rhs::Index.Type) = Index.Div(lhs, rhs)
Base.:(\)(lhs::Index.Type, rhs::Index.Type) = rhs / lhs
Base.:(\)(lhs::Index.Type, rhs::Int) = rhs / lhs
Base.:(\)(lhs::Int, rhs::Index.Type) = rhs / lhs
Base.:(^)(lhs::Index.Type, rhs::Index.Type) = Index.Pow(lhs, rhs)
Base.:(^)(lhs::Index.Type, rhs::Int) = Index.Pow(lhs, rhs)
Base.:(^)(lhs::Int, rhs::Index.Type) = Index.Pow(lhs, rhs)
Base.rem(lhs::Index.Type, rhs::Index.Type) = Index.Rem(lhs, rhs)
Base.rem(lhs::Index.Type, rhs::Int) = Index.Rem(lhs, rhs)
Base.rem(lhs::Int, rhs::Index.Type) = Index.Rem(lhs, rhs)
Base.min(lhs::Index.Type, rhs::Index.Type) = Index.Min(lhs, rhs)
Base.min(lhs::Index.Type, rhs::Int) = Index.Min(lhs, rhs)
Base.min(lhs::Int, rhs::Index.Type) = Index.Min(lhs, rhs)
Base.max(lhs::Index.Type, rhs::Index.Type) = Index.Max(lhs, rhs)
Base.max(lhs::Index.Type, rhs::Int) = Index.Max(lhs, rhs)
Base.max(lhs::Int, rhs::Index.Type) = Index.Max(lhs, rhs)

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
"""
    @scalar_str

Create a `Scalar.Variable` from a string.
"""
macro scalar_str(s::AbstractString)
    return parse_var(Scalar.Variable, s)
end

"""
    @index_str

Create a `Index.Variable` from a string.
"""
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

const ħ = Scalar.Hbar
