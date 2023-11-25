function Tree.inline_print(io::IO, x::Num.Type)
    @match x begin
        Num.Zero => print(io, "0")
        Num.One => print(io, "1")
        Num.Real(x) => print(io, pprint_real(x))
        Num.Imag(x) => print(io, pprint_real(x), "*im")
        Num.Complex(x, y) => print(io, pprint_real(x), "+", pprint_real(y), "*im")
    end
end

function pprint_real(x::Float64)
    if isinteger(x)
        return Int64(x)
    else
        return x
    end
end
