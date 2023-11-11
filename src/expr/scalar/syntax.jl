for op in [:+, :-, :*, :/, :\]
    @eval function Base.$(op)(lhs::Num.Type, rhs::Num.Type)
        return Base.$(op)(Number(lhs), Number(rhs))
    end

    @eval function Base.$(op)(lhs::Num.Type, rhs::Number)
        return Base.$(op)(Number(lhs), rhs)
    end

    @eval function Base.$(op)(lhs::Number, rhs::Num.Type)
        return Base.$(op)(rhs, lhs)
    end
end

# some overloads for the syntax of scalar expressions
function Base.:(+)(lhs::Scalar.Type, rhs::Scalar.Type)
    @match (lhs, rhs) begin
        (Scalar.Constant(x), Scalar.Constant(y)) => Scalar.Constant(x + y)
        (_, Scalar.Constant(_)) => Scalar.Sum(rhs, Dict(lhs => 1))
        (Scalar.Constant(_), _) => Scalar.Sum(lhs, Dict(rhs => 1))
        _ => Scalar.Sum(Scalar.Constant(0), Dict(lhs => 1, rhs => 1))
    end
end

# function Base.:(*)(lhs::Scalar.Type, rhs::Scalar.Type)
#     @match (lhs, rhs) begin
#         (Scalar.Constant(x), Scalar.Constant(y)) => Scalar.Constant(Number(x) * Number(y))
#         (Scalar.Constant(x), Scalar.Variable(y)) => Scalar.Prod(x, Dict(y => 1))
#     end
# end
