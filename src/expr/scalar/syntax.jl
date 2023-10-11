# some overloads for the syntax of scalar expressions
function Base.:(+)(lhs::Scalar.Type, rhs::Scalar.Type)
    if isa_variant(lhs, Scalar.Constant) && isa_variant(rhs, Scalar.Constant)
        Scalar.Constant(Number(lhs.:1) + Number(rhs.:1))
    elseif isa_variant(rhs, Scalar.Constant)
        Scalar.Sum(rhs, Dict(lhs => 1))
    elseif isa_variant(lhs, Scalar.Constant)
        Scalar.Sum(lhs, Dict(rhs => 1))
    else
        Scalar.Sum(Scalar.Constant(0), Dict(lhs => 1, rhs => 1))
    end
end
