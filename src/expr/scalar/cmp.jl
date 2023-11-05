function Base.:(==)(lhs::Num.Type, rhs::Num.Type)
    variant_type(lhs) === variant_type(rhs) || return false
    return @match (lhs, rhs) begin
        (Num.Real(x), Num.Real(y)) => x == y
        (Num.Imag(x), Num.Imag(y)) => x == y
        (Num.Complex(x, y), Num.Complex(a, b)) => x == a && y == b
        _ => true
    end
end

function Base.:(==)(lhs::Num.Type, rhs::Number)
    return @match lhs begin
        Num.Zero => iszero(rhs)
        Num.One => isone(rhs)
        Num.Real(x) => x == rhs
        Num.Imag(x) => im * x == rhs
        Num.Complex(x, y) => Complex(x, y) == rhs
        Num.Pi => rhs == pi
        Num.Euler => rhs == ℯ
    end
end
