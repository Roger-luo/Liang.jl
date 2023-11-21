function Tree.inline_print(io::IO, x::Num.Type)
    @match x begin
        Num.Zero => print(io, "0")
        Num.One => print(io, "1")
        Num.Real(x) => print(io, x)
        Num.Imag(x) => print(io, x, "*im")
        Num.Complex(x, y) => print(io, x, "+", y, "*im")
    end
end
