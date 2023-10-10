using ExproniconLite
using Liang.Data: Data, Emit, TypeDef, EmitInfo

abstract type MySuper end
def = TypeDef(Main, :(MyADT <: MySuper), quote
    Foo
    Bar(Int, Float64)

    struct Baz
        x::Int
        y::Float64
        z::Vector{MyADT}
    end
end)

info = EmitInfo(def)
eval(Emit.emit(info))

print_expr(Emit.emit(info))

MyADT.Type|>dump
MyADT.var"#MyADT#Variant"(0)()
MyADT.var"#MyADT#Variant"(1)(1, 2.0)
x = MyADT.var"#MyADT#Variant"(2)(1, 2.0, [MyADT.var"#MyADT#Variant"(0)(), MyADT.var"#MyADT#Variant"(1)(1, 2.0)])
MyADT.Foo
MyADT.Bar
MyADT.Baz(1, 2, [MyADT.Foo, MyADT.Bar(1, 2.0)])

Data.show_variant(stdout, MyADT.Bar)
Data.show_variant(stdout, MIME"text/plain"(), MyADT.Bar)
MyADT.Bar
TestModule.Main.Baz(1, 2, [TestModule.Main.Foo])
