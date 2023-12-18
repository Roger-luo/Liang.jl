



for op in (:+, :-, :*)
    @eval function LinearAlgebra.$op(lhs::OpValue.Type, rhs::OpValue.Type)::OpValue.Type
        return LinearAlgebra.$op(mat(lhs), mat(rhs))
    end
end

function LinearAlgebra.kron(lhs::OpValue.Type, rhs::OpValue.Type)::OpValue.Type
    return kron(mat(lhs), mat(rhs))
end
    

for unaryop in (:det, :tr)
    @eval function LinearAlgebra.$unaryop(op::OpValue.Type)::Scalar.Type
        return LinearAlgebra.$unaryop(mat(op))
    end
end

partial_trace(op::OpValue.Type, m::Int, n::Int)::Op.Type = partial_trace(mat(op), m, n)
