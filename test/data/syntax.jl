using Liang.Data: TypeDef

TypeDef(Main, :MyADT, quote
    Foo
    Bar(Int, Float64)

    struct Baz
        x::Int
        y::Float64
        z::Vector{MyADT}
    end
end)