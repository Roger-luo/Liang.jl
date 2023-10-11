Base.convert(::Type{Num.Type}, x::Real) = Num.Real(x)
Base.convert(::Type{Num.Type}, x::Complex) = if iszero(imag(x))
    Num.Real(real(x))
elseif iszero(real(x))
    Num.Imag(imag(x))
else
    Num.Complex(real(x), imag(x))
end
Base.convert(::Type{Num.Type}, x::typeof(MathConstants.e)) = Num.Euler
Base.convert(::Type{Num.Type}, x::typeof(pi)) = Num.Pi

Base.convert(::Type{Scalar.Type}, x::Num.Type) = Scalar.Constant(x)
Base.convert(::Type{Scalar.Type}, x::Number) = Scalar.Constant(convert(Num.Type, x))

# backwards conversion
function onlyif_constant(f, x::Scalar.Type)
    if isa_variant(x, Scalar.Constant)
        return f(x)
    else
        error("Expect a constant scalar, got $x")
    end
end

Base.convert(::Type{Num.Type}, x::Scalar.Type) = onlyif_constant(x->x.:1, x)
Base.convert(::Type{T}, x::Num.Type) where {T <: Number} = if isa_variant(x, Num.Real)
    return x.:1
elseif isa_variant(x, Num.Imag)
    return convert(T, x.:1) * im
elseif isa_variant(x, Num.Complex)
    return convert(T, Complex(x.:1, x.:2))
elseif isa_variant(x, Num.Pi)
    return convert(T, pi)
elseif isa_variant(x, Num.Euler)
    return convert(T, MathConstants.e)
else
    error("Expect a real number, got $x")
end

Base.convert(::Type{T}, x::Scalar.Type) where {T <: Real} = convert(T, onlyif_constant(x->x.:1, x))
Base.convert(::Type{T}, x::Scalar.Type) where {T <: Complex} = convert(T, onlyif_constant(x->x.:1, x))

(::Type{T})(x::Num.Type) where {T <: Number} = convert(T, x)
(::Type{T})(x::Scalar.Type) where {T <: Number} = convert(T, x)
