function Base.show(io::IO, x::Domain.Type)
    @match x begin
        Domain.Natural => print(io, "ℕ")
        Domain.Integer => print(io, "ℤ")
        Domain.Rational => print(io, "ℚ")
        Domain.Real => print(io, "ℝ")
        Domain.Imag => print(io, "ℑ")
        Domain.Complex => print(io, "ℂ")
        Domain.Unknown => print(io, "⊤")
    end
end

function Base.show(io::IO, x::Num.Type)
    function pretty(x::Float64)
        if isinteger(x)
            return Int64(x)
        else
            return x
        end
    end

    @match x begin
        Num.Zero => print(io, "0")
        Num.One => print(io, "1")
        Num.Real(x) => print(io, pretty(x))
        Num.Imag(x) && if isone(x)
        end => print(io, "im")
        Num.Imag(x) && if isone(-x)
        end => print(io, "-im")
        Num.Imag(x) => print(io, pretty(x), "*im")
        Num.Complex(x, y) && if isone(y)
        end => print(io, pretty(x), "+im")
        Num.Complex(x, y) && if isone(-y)
        end => print(io, pretty(x), "-im")
        Num.Complex(x, y) => print(io, pretty(x), "+", pretty(y), "*im")
    end
end

function Base.show(io::IO, node::Scalar.Type)
    return Tree.Print.inline(io, node)
end
