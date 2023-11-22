Base.convert(::Type{Index.Type}, x::Int) = Index.Constant(x)
Base.convert(::Type{Index.Type}, x::Symbol) = Index.Variable(; name=x)

Base.convert(::Type{Num.Type}, x::Real) =
    if iszero(x)
        Num.Zero
    elseif isone(x)
        Num.One
    else
        Num.Real(x)
    end

Base.convert(::Type{Num.Type}, x::Complex) =
    if iszero(imag(x))
        Num.Real(real(x))
    elseif iszero(real(x))
        Num.Imag(imag(x))
    else
        Num.Complex(real(x), imag(x))
    end

# Base.convert(::Type{Num.Type}, x::typeof(MathConstants.e)) = Num.Euler
# Base.convert(::Type{Num.Type}, x::typeof(pi)) = Num.Pi

Base.convert(::Type{Scalar.Type}, x::Num.Type) = Scalar.Constant(x)
Base.convert(::Type{Scalar.Type}, x::Number) =
    if x isa Irrational{:π}
        Scalar.Pi
    elseif x isa Irrational{:ℯ}
        Scalar.Euler
    else
        Scalar.Constant(convert(Num.Type, x))
    end

# backwards conversion
Base.convert(::Type{Int}, x::Index.Type) =
    if isa_variant(x, Index.Constant)
        return x.:1
    else
        error("Expect a constant index, got $x")
    end

Base.convert(::Type{Symbol}, x::Index.Type) =
    if isa_variant(x, Index.Variable)
        return x.name
    else
        error("Expect a variable index, got $x")
    end

function onlyif_constant(f, x::Scalar.Type)
    if isa_variant(x, Scalar.Constant)
        return f(x)
    else
        error("Expect a constant scalar, got $x")
    end
end

Base.convert(::Type{Num.Type}, x::Scalar.Type) = begin
    onlyif_constant(x -> x.:1, x)
end

function Base.convert(::Type{T}, x::Num.Type) where {T<:Number}
    if isa_variant(x, Num.Real)
        return x.:1
    elseif isa_variant(x, Num.Zero)
        return zero(T)
    elseif isa_variant(x, Num.One)
        return one(T)
    elseif isa_variant(x, Num.Imag)
        return convert(T, x.:1) * im
    elseif isa_variant(x, Num.Complex)
        return convert(T, Complex(x.:1, x.:2))
        # elseif isa_variant(x, Num.Pi)
        #     return convert(T, pi)
        # elseif isa_variant(x, Num.Euler)
        #     return convert(T, MathConstants.e)
    else
        error("Expect a real number, got $x")
    end
end

function Base.convert(::Type{T}, x::Scalar.Type) where {T<:Number}
    @match x begin
        Scalar.Constant(y) => return convert(T, y)
        Scalar.Pi => return convert(T, pi)
        Scalar.Euler => return convert(T, MathConstants.e)
        Scalar.Hbar => error("cannot convert Hbar to a number without units")
        _ => error("Expect a constant scalar, got $x")
    end
end

(::Type{T})(x::Num.Type) where {T<:Number} = convert(T, x)
(::Type{T})(x::Scalar.Type) where {T<:Number} = convert(T, x)

function Base.convert(::Type{Scalar.Type}, x::Index.Type)
    @match x begin
        Index.Constant(y) => return Scalar.Constant(y)
        Index.Variable(; name, id) => return Scalar.Variable(; name, id)
        Index.Add(x, y) => return convert(Scalar.Type, x) + convert(Scalar.Type, y)
        Index.Sub(x, y) => return convert(Scalar.Type, x) - convert(Scalar.Type, y)
        Index.Mul(x, y) => return convert(Scalar.Type, x) * convert(Scalar.Type, y)
        Index.Div(x, y) => return convert(Scalar.Type, x) / convert(Scalar.Type, y)
        Index.Pow(x, y) => return convert(Scalar.Type, x)^convert(Scalar.Type, y)
        Index.Neg(x) => return -convert(Scalar.Type, x)
        Index.Abs(x) => return abs(convert(Scalar.Type, x))
        Index.Wildcard => return Scalar.Wildcard
        Index.Match(name) => return Scalar.Match(name)
        Index.NSites(name, id) => error("cannot convert NSites to Scalar")
        Index.AssertEqual(lhs, rhs, msg) => error("cannot convert AssertEqual to Scalar")
        _ => error("Expect a constant index, got $x")
    end
end
