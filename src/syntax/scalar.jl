@syntax function Traits.Domain.domain(expr::Scalar.Type, x::Domain.Type)
    return Scalar.Domain(expr, x)
end

function domain2int(x::Domain.Type)
    @match x begin
        Domain.Natural => 0
        Domain.Integer => 1
        Domain.Rational => 2
        Domain.Real => 3
        Domain.Imag => 4
        Domain.Complex => 5
        Domain.Unknown => 100
    end
end

function int2domain(x::Int)
    @match x begin
        0 => Domain.Natural
        1 => Domain.Integer
        2 => Domain.Rational
        3 => Domain.Real
        4 => Domain.Imag
        5 => Domain.Complex
        100 => Domain.Unknown
    end
end

function Base.union(lhs::Domain.Type, rhs::Domain.Type)
    return int2domain(max(domain2int(lhs), domain2int(rhs)))
end

function Base.real(x::Domain.Type)
    @match x begin
        Domain.Imag => Domain.Real
        Domain.Complex => Domain.Real
        Domain.Unknown => Domain.Real
        _ => x
    end
end

for fn in [:exp, :log, :sqrt]
    @eval function Base.$fn(x::Domain.Type)
        @match x begin
            Domain.Natural => Domain.Real
            Domain.Integer => Domain.Real
            Domain.Rational => Domain.Real
            Domain.Real => Domain.Real
            Domain.Imag => Domain.Complex
            Domain.Complex => Domain.Complex
            Domain.Unknown => Domain.Unknown
        end
    end
end

function Base.:(+)(lhs::Domain.Type, rhs::Domain.Type)
    @match (lhs, rhs) begin
        (_, Domain.Unknown) || (Domain.Unknown, _) => Domain.Unknown

        (Domain.Natural, Domain.Natural) => Domain.Natural
        (Domain.Natural, Domain.Integer) => Domain.Integer
        (Domain.Natural, Domain.Rational) => Domain.Rational
        (Domain.Natural, Domain.Real) => Domain.Real
        (Domain.Natural, Domain.Imag) => Domain.Complex
        (Domain.Natural, Domain.Complex) => Domain.Complex

        (Domain.Integer, Domain.Natural) => Domain.Integer
        (Domain.Integer, Domain.Integer) => Domain.Integer
        (Domain.Integer, Domain.Rational) => Domain.Rational
        (Domain.Integer, Domain.Real) => Domain.Real
        (Domain.Integer, Domain.Imag) => Domain.Complex
        (Domain.Integer, Domain.Complex) => Domain.Complex

        (Domain.Rational, Domain.Natural) => Domain.Rational
        (Domain.Rational, Domain.Integer) => Domain.Rational
        (Domain.Rational, Domain.Rational) => Domain.Rational
        (Domain.Rational, Domain.Real) => Domain.Real
        (Domain.Rational, Domain.Imag) => Domain.Complex
        (Domain.Rational, Domain.Complex) => Domain.Complex

        (Domain.Real, Domain.Natural) => Domain.Real
        (Domain.Real, Domain.Integer) => Domain.Real
        (Domain.Real, Domain.Rational) => Domain.Real
        (Domain.Real, Domain.Real) => Domain.Real
        (Domain.Real, Domain.Imag) => Domain.Complex
        (Domain.Real, Domain.Complex) => Domain.Complex

        (Domain.Imag, _) || (_, Domain.Imag) => Domain.Complex
        (Domain.Complex, _) || (_, Domain.Complex) => Domain.Complex
    end
end

function Base.:(*)(lhs::Domain.Type, rhs::Domain.Type)
    @match (lhs, rhs) begin
        (_, Domain.Unknown) || (Domain.Unknown, _) => Domain.Unknown

        (Domain.Natural, Domain.Natural) => Domain.Natural
        (Domain.Natural, Domain.Integer) => Domain.Integer
        (Domain.Natural, Domain.Rational) => Domain.Rational
        (Domain.Natural, Domain.Real) => Domain.Real
        (Domain.Natural, Domain.Imag) => Domain.Complex
        (Domain.Natural, Domain.Complex) => Domain.Complex

        (Domain.Integer, Domain.Natural) => Domain.Integer
        (Domain.Integer, Domain.Integer) => Domain.Integer
        (Domain.Integer, Domain.Rational) => Domain.Rational
        (Domain.Integer, Domain.Real) => Domain.Real
        (Domain.Integer, Domain.Imag) => Domain.Complex
        (Domain.Integer, Domain.Complex) => Domain.Complex

        (Domain.Rational, Domain.Natural) => Domain.Rational
        (Domain.Rational, Domain.Integer) => Domain.Rational
        (Domain.Rational, Domain.Rational) => Domain.Rational
        (Domain.Rational, Domain.Real) => Domain.Real
        (Domain.Rational, Domain.Imag) => Domain.Complex
        (Domain.Rational, Domain.Complex) => Domain.Complex

        (Domain.Real, Domain.Natural) => Domain.Real
        (Domain.Real, Domain.Integer) => Domain.Real
        (Domain.Real, Domain.Rational) => Domain.Real
        (Domain.Real, Domain.Real) => Domain.Real
        (Domain.Real, Domain.Imag) => Domain.Complex
        (Domain.Real, Domain.Complex) => Domain.Complex

        (Domain.Imag, _) || (_, Domain.Imag) => Domain.Complex
        (Domain.Complex, _) || (_, Domain.Complex) => Domain.Complex
    end
end

function Base.:(^)(base::Domain.Type, exp::Domain.Type)
    @match (base, exp) begin
        (_, Domain.Unknown) || (Domain.Unknown, _) => Domain.Unknown

        (Domain.Natural, Domain.Natural) => Domain.Natural
        (Domain.Natural, Domain.Integer) => Domain.Real
        (Domain.Natural, Domain.Rational) => Domain.Real
        (Domain.Natural, Domain.Real) => Domain.Real
        (Domain.Natural, Domain.Imag) => Domain.Complex
        (Domain.Natural, Domain.Complex) => Domain.Complex

        (Domain.Integer, Domain.Natural) => Domain.Integer
        (Domain.Integer, Domain.Integer) => Domain.Real
        (Domain.Integer, Domain.Rational) => Domain.Real
        (Domain.Integer, Domain.Real) => Domain.Real
        (Domain.Integer, Domain.Imag) => Domain.Complex
        (Domain.Integer, Domain.Complex) => Domain.Complex

        (Domain.Rational, Domain.Natural) => Domain.Rational
        (Domain.Rational, Domain.Integer) => Domain.Rational
        (Domain.Rational, Domain.Rational) => Domain.Real
        (Domain.Rational, Domain.Real) => Domain.Real
        (Domain.Rational, Domain.Imag) => Domain.Complex
        (Domain.Rational, Domain.Complex) => Domain.Complex

        (Domain.Real, Domain.Natural) => Domain.Real
        (Domain.Real, Domain.Integer) => Domain.Real
        (Domain.Real, Domain.Rational) => Domain.Real
        (Domain.Real, Domain.Real) => Domain.Real
        (Domain.Real, Domain.Imag) => Domain.Complex
        (Domain.Real, Domain.Complex) => Domain.Complex
        (Domain.Real, Domain.Unknown) => Domain.Unknown

        (Domain.Imag, _) || (_, Domain.Imag) => Domain.Complex
        (Domain.Complex, _) || (_, Domain.Complex) => Domain.Complex
    end
end

function Base.:(/)(lhs::Domain.Type, rhs::Domain.Type)
    @match (lhs, rhs) begin
        (_, Domain.Unknown) || (Domain.Unknown, _) => Domain.Unknown

        (Domain.Natural, Domain.Natural) => Domain.Rational
        (Domain.Natural, Domain.Integer) => Domain.Rational
        (Domain.Natural, Domain.Rational) => Domain.Rational
        (Domain.Natural, Domain.Real) => Domain.Real
        (Domain.Natural, Domain.Imag) => Domain.Complex
        (Domain.Natural, Domain.Complex) => Domain.Complex

        (Domain.Integer, Domain.Natural) => Domain.Rational
        (Domain.Integer, Domain.Integer) => Domain.Rational
        (Domain.Integer, Domain.Rational) => Domain.Rational
        (Domain.Integer, Domain.Real) => Domain.Real
        (Domain.Integer, Domain.Imag) => Domain.Complex
        (Domain.Integer, Domain.Complex) => Domain.Complex

        (Domain.Rational, Domain.Natural) => Domain.Rational
        (Domain.Rational, Domain.Integer) => Domain.Rational
        (Domain.Rational, Domain.Rational) => Domain.Rational
        (Domain.Rational, Domain.Real) => Domain.Real
        (Domain.Rational, Domain.Imag) => Domain.Complex
        (Domain.Rational, Domain.Complex) => Domain.Complex

        (Domain.Real, Domain.Natural) => Domain.Real
        (Domain.Real, Domain.Integer) => Domain.Real
        (Domain.Real, Domain.Rational) => Domain.Real
        (Domain.Real, Domain.Real) => Domain.Real
        (Domain.Real, Domain.Imag) => Domain.Complex
        (Domain.Real, Domain.Complex) => Domain.Complex
        (Domain.Real, Domain.Unknown) => Domain.Unknown

        (Domain.Imag, _) || (_, Domain.Imag) => Domain.Complex
        (Domain.Complex, _) || (_, Domain.Complex) => Domain.Complex
    end
end

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

function Base.conj(x::Num.Type)
    @match x begin
        Num.Zero => Num.Zero
        Num.One => Num.One
        Num.Real(x) => Num.Real(x)
        Num.Imag(x) => Num.Imag(-x)
        Num.Complex(x, y) => Num.Complex(x, -y)
    end
end

@syntax Base.conj(x::Scalar.Type) = Scalar.Conj(x)
@syntax Base.:(+)(x::Scalar.Type) = x
@syntax Base.:(-)(x::Scalar.Type) = Scalar.Neg(x)

# some overloads for the syntax of scalar expressions
@syntax Base.:(+)(lhs::Scalar.Type, rhs::Number) = lhs + Scalar.Constant(rhs)
@syntax Base.:(+)(lhs::Number, rhs::Scalar.Type) = Scalar.Constant(lhs) + rhs
@syntax Base.:(+)(lhs::Scalar.Type, rhs::Num.Type) = lhs + Scalar.Constant(rhs)
@syntax Base.:(+)(lhs::Num.Type, rhs::Scalar.Type) = Scalar.Constant(lhs) + rhs

@syntax function Base.:(+)(lhs::Scalar.Type, rhs::Scalar.Type)
    @match (lhs, rhs) begin
        (Scalar.Constant(x), Scalar.Constant(y)) => Scalar.Constant(x + y)
        (_, Scalar.Constant(_)) => Scalar.Add(rhs, Dict(lhs => 1))
        (Scalar.Constant(_), _) => Scalar.Add(lhs, Dict(rhs => 1))
        (x, x) => Scalar.Add(Scalar.Constant(0), Dict(x => 2))
        _ => Scalar.Add(Scalar.Constant(0), Dict(lhs => 1, rhs => 1))
    end
end

@syntax Base.:(-)(lhs::Scalar.Type, rhs::Number) = lhs - Scalar.Constant(rhs)
@syntax Base.:(-)(lhs::Number, rhs::Scalar.Type) = Scalar.Constant(lhs) - rhs
@syntax Base.:(-)(lhs::Scalar.Type, rhs::Num.Type) = lhs - Scalar.Constant(rhs)
@syntax Base.:(-)(lhs::Num.Type, rhs::Scalar.Type) = Scalar.Constant(lhs) - rhs

@syntax function Base.:(-)(lhs::Scalar.Type, rhs::Scalar.Type)
    @match (lhs, rhs) begin
        (Scalar.Constant(x), Scalar.Constant(y)) => Scalar.Constant(x - y)
        (_, Scalar.Constant(_)) => Scalar.Add(-rhs, Dict(lhs => 1))
        (Scalar.Constant(_), _) => Scalar.Add(lhs, Dict(rhs => -1))
        (x, x) => Scalar.Constant(0)
        _ => Scalar.Add(Scalar.Constant(0), Dict(lhs => 1, rhs => -1))
    end
end

@syntax Base.:(*)(lhs::Scalar.Type, rhs::Number) = lhs * Scalar.Constant(rhs)
@syntax Base.:(*)(lhs::Number, rhs::Scalar.Type) = Scalar.Constant(lhs) * rhs
@syntax Base.:(*)(lhs::Scalar.Type, rhs::Num.Type) = lhs * Scalar.Constant(rhs)
@syntax Base.:(*)(lhs::Num.Type, rhs::Scalar.Type) = Scalar.Constant(lhs) * rhs

@syntax function Base.:(*)(lhs::Scalar.Type, rhs::Scalar.Type)
    @match (lhs, rhs) begin
        (Scalar.Constant(x), Scalar.Constant(y)) => Scalar.Constant(x * y)
        (_, Scalar.Constant(_)) => Scalar.Mul(rhs, Dict(lhs => 1))
        (Scalar.Constant(_), _) => Scalar.Mul(lhs, Dict(rhs => 1))
        (x, x) => Scalar.Pow(x, Scalar.Constant(2))
        _ => Scalar.Mul(Scalar.Constant(1), Dict(lhs => 1, rhs => 1))
    end
end

@syntax Base.:(/)(lhs::Scalar.Type, rhs::Number) = lhs / Scalar.Constant(rhs)
@syntax Base.:(/)(lhs::Number, rhs::Scalar.Type) = Scalar.Constant(lhs) / rhs
@syntax Base.:(/)(lhs::Scalar.Type, rhs::Num.Type) = lhs / Scalar.Constant(rhs)
@syntax Base.:(/)(lhs::Num.Type, rhs::Scalar.Type) = Scalar.Constant(lhs) / rhs

@syntax function Base.:(/)(lhs::Scalar.Type, rhs::Scalar.Type)
    lhs == rhs && return Scalar.Constant(1)
    return Scalar.Div(lhs, rhs)
end

@syntax Base.:(\)(lhs::Scalar.Type, rhs::Number) = lhs \ Scalar.Constant(rhs)
@syntax Base.:(\)(lhs::Number, rhs::Scalar.Type) = Scalar.Constant(lhs) \ rhs
@syntax Base.:(\)(lhs::Scalar.Type, rhs::Num.Type) = lhs \ Scalar.Constant(rhs)
@syntax Base.:(\)(lhs::Num.Type, rhs::Scalar.Type) = Scalar.Constant(lhs) \ rhs
@syntax function Base.:(\)(lhs::Scalar.Type, rhs::Scalar.Type)
    lhs == rhs && return Scalar.Constant(1)
    return Scalar.Div(rhs, lhs)
end

@syntax Base.:(^)(lhs::Scalar.Type, rhs::Number) = lhs^Scalar.Constant(rhs)
@syntax Base.:(^)(lhs::Number, rhs::Scalar.Type) = Scalar.Constant(lhs)^rhs
@syntax Base.:(^)(lhs::Scalar.Type, rhs::Num.Type) = lhs^Scalar.Constant(rhs)
@syntax Base.:(^)(lhs::Num.Type, rhs::Scalar.Type) = Scalar.Constant(lhs)^rhs
@syntax function Base.:(^)(lhs::Scalar.Type, rhs::Scalar.Type)
    return Scalar.Pow(lhs, rhs)
end

@syntax Base.abs(x::Scalar.Type) = Scalar.Abs(x)
@syntax Base.exp(x::Scalar.Type) = Scalar.Exp(x)
@syntax Base.log(x::Scalar.Type) = Scalar.Log(x)
@syntax Base.sqrt(x::Scalar.Type) = Scalar.Sqrt(x)
@syntax Base.max(xs::Scalar.Type...) = Scalar.Max(Set(xs))
@syntax Base.min(xs::Scalar.Type...) = Scalar.Min(Set(xs))

# variable syntax
"""
    @scalar_str

Create a `Scalar.Variable` from a string.
"""
macro scalar_str(s::AbstractString)
    return parse_var(Scalar.Variable, s)
end

"""
    @int_str

Create a `Scalar.Variable` from a string annotated
with `Domain.Integer`.
"""
macro int_str(s::AbstractString)
    return Scalar.Domain(parse_var(Scalar.Variable, s), Domain.Integer)
end

"""
    @nat_str

Create a `Scalar.Variable` from a string annotated
with `Domain.Natural`.
"""
macro nat_str(s::AbstractString)
    return Scalar.Domain(parse_var(Scalar.Variable, s), Domain.Natural)
end

"""
    @rat_str

Create a `Scalar.Variable` from a string annotated
with `Domain.Rational`.
"""
macro rat_str(s::AbstractString)
    return Scalar.Domain(parse_var(Scalar.Variable, s), Domain.Rational)
end

"""
    @real_str

Create a `Scalar.Variable` from a string annotated
with `Domain.Real`.
"""
macro real_str(s::AbstractString)
    return Scalar.Domain(parse_var(Scalar.Variable, s), Domain.Real)
end

"""
    @imag_str

Create a `Scalar.Variable` from a string annotated
with `Domain.Imag`.
"""
macro imag_str(s::AbstractString)
    return Scalar.Domain(parse_var(Scalar.Variable, s), Domain.Imag)
end

"""
    @complex_str

Create a `Scalar.Variable` from a string annotated
with `Domain.Complex`.
"""
macro complex_str(s::AbstractString)
    return Scalar.Domain(parse_var(Scalar.Variable, s), Domain.Complex)
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
    :log10,
    :log1p,
    :log2,
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
]
    @eval @syntax Base.$fn(x::Scalar.Type) = Scalar.JuliaCall(Base, $(QuoteNode(fn)), [x])
end

const ħ = Scalar.Hbar

@static if VERSION > v"1.10-"
    for fn in [:fourthroot, :tanpi]
        @eval @syntax Base.$fn(x::Scalar.Type) =
            Scalar.JuliaCall(Base, $(QuoteNode(fn)), [x])
    end
end
