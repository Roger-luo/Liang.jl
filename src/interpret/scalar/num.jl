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

Base.:(+)(x::Num.Type) = x
Base.:(-)(x::Num.Type) = @match x begin
    Num.Zero => 0
    Num.One => 1
    Num.Real(v) => -v
    Num.Imag(v) => -v * im
    Num.Complex(a, b) => ComplexF64(-a, -b)
end

for fn in [
    :abs,
    :exp,
    :log,
    :sqrt,
    :max,
    :min,
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
    @eval function Base.$fn(x::Num.Type)
        return Base.$fn(Number(x))
    end
end # for

@static if VERSION > v"1.10-"
    for fn in [:fourthroot, :tanpi]
        @eval Base.$fn(x::Num.Type) = Base.$fn(Number(x))
    end
end
