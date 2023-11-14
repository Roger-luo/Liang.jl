using Liang.Data
using Liang.Expression: Scalar, Num, Index, @scalar_str, @index_str, @routine_str

scalar"x" * (scalar"%1" * 2.5 + 1)
routine"foo"(scalar"x", scalar"x" + 1)

x = Num.Real(1.0)
convert(Real, Num.Real(1.0))

Real(Scalar.Constant(Num.Real(1.0)))
Complex(Scalar.Constant(1 + 2im))
Scalar.Constant(pi)
names(@__MODULE__; all=true, imported=true)
Scalar.Wildcard
Scalar.Div(Scalar.Constant(Num.Real(1.0)), Scalar.Constant(Num.Complex(2.0, 3.0)))
x = Scalar.Sum(;
    coeffs=1.0, terms=Dict(Scalar.Constant(1.0) => 1.0, Scalar.Constant(2.0) => 2.0)
)

Scalar.Constant(1.5) + Scalar.Variable(:x)
Scalar.Variable(:x) + Scalar.Variable(:y)

using Liang.Expression: Scalar, Num
using Liang.Data.Prelude
using Liang.Match: @match

# TODO: use Cthulu to investigate why this is not stable
function foo(x)
    isa_variant(x, Scalar.Constant) && return (x.:1)::Num.Type
    isa_variant(x, Scalar.Sum) && return (x.:2)::Dict{Scalar.Type,Num.Type}
    return error("unreachable")
    # @match x begin
    #     Scalar.Constant(y) => y::Num.Type
    #     Scalar.Sum(coeffs, terms) => coeffs::Num.Type
    # end
end

x = Scalar.Sum(;
    coeffs=1.0, terms=Dict(Scalar.Constant(1.0) => 1.0, Scalar.Constant(2.0) => 2.0)
)
foo(x)

@code_warntype foo(x)

@descend foo(x)

x = Num.Real(1.0)
hash(x, UInt64(0x01))
@code_warntype hash(x, UInt64(0x01))

Num.Real(1.0) == Num.Real(1.0)
@code_warntype Num.Real(1.0) == Num.Real(1.0)
x = Scalar.Constant(1.5)
y = Scalar.Constant(1.5)

@code_warntype x == y
@code_warntype hash(x, UInt64(0x01))
hash(y)
hash(x, UInt64(0x01))

variant_tag(x) == variant_tag(y)
for name in variant_fieldnames(x)
    getproperty(x, name) == getproperty(y, name)
end

@code_warntype Index.Wildcard * 3 / Index.Variable(:a)
