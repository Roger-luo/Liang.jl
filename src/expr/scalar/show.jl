function Data.show_data(io::IO, x::Num.Type)
    f = Data.FormatPrinter(io)
    if isa_variant(x, Num.Pi)
        return f.print("Num.Pi")
    elseif isa_variant(x, Num.Euler)
        return f.print("Num.Euler")
    elseif isa_variant(x, Num.Zero)
        return f.print("Num.Zero")
    elseif isa_variant(x, Num.One)
        return f.print("Num.One")
    end

    f.show(Data.variant_type(x))
    f.print("(")
    if isa_variant(x, Num.Real)
        f.print(x.:1)
    elseif isa_variant(x, Num.Imag)
        f.print(x.:1, "*im")
    elseif isa_variant(x, Num.Complex)
        f.print(x.:1, "+", x.:2, "*im")
    end
    f.print(")")
end
